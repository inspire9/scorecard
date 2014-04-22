class Scorecard::Board
  include Enumerable

  def initialize(model, options = {})
    @model, @options = model, options
  end

  def each(&block)
    to_a.each &block
  end

  def to_a
    query.collect { |point| [point.user, point.amount] }
  end

  private

  attr_reader :model, :options

  def query
    relation = Scorecard::Point.highest_first
    relation = relation.join_against model
    relation = relation.summary_with model

    relation = relation.for_user_ids model, options[:users] if options[:users]
    relation = relation.since options[:since]               if options[:since]
    relation
  end
end
