class Carmack::PointRule
  cattr_accessor :rules
  attr_accessor :context, :amount, :condition

  self.rules = []

  def self.find(context)
    rules.detect { |rule| rule.context == context }
  end

  def initialize(context, amount, &condition)
    @context, @amount, @condition = context, amount, condition

    self.class.rules << self
  end

  def allowed?(payload)
    condition.nil? || condition.call(payload)
  end
end
