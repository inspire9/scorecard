class Scorecard::Board
  include Enumerable

  def initialize(options = {})
    @options = options
  end

  def each(&block)
    to_a.each &block
  end

  def to_a
    query.collect { |point|
      {point.user => point.amount}
    }
  end

  private

  attr_reader :options

  def query
    relation = Scorecard::Point.summary.highest_first
    relation = relation.for_users(*options[:users]) if options[:users]
    relation = relation.since(options[:since])      if options[:since]
    relation
  end
end
