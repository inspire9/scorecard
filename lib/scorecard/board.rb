class Scorecard::Board
  include Enumerable

  def initialize(model, options = {})
    @model, @options = model, options
  end

  def each(&block)
    to_a.each &block
  end

  def to_a
    model.connection.select_all(query).collect { |row|
      [model.find(row['id']), row['sum_amount'].to_i]
    }
  end

  private

  attr_reader :model, :options

  def query
    subquery = Scorecard::Point.select('user_id, amount').
      where user_type: model.name
    subquery = subquery.since options[:since]               if options[:since]
    subquery = subquery.within options[:within]             if options[:within]
    subquery = subquery.for_user_ids model, options[:users] if options[:user]

    query = model.select("id, COALESCE(SUM(sp.amount), 0) AS sum_amount").
      joins("LEFT OUTER JOIN (#{subquery.to_sql}) AS sp ON sp.user_id = id").
      group('id').order('sum_amount DESC')
    query = query.where id: options[:users] if options[:users]
    query = query.limit options[:limit]     if options[:limit]
    query = query.offset page_offset        if paged?
    query.to_sql
  end

  def page
    options[:page].present? ? options[:page].to_i : 1
  end

  def paged?
    options[:page].present?
  end

  def page_offset
    (page - 1) * options[:limit]
  end
end
