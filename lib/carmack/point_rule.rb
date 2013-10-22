class Carmack::PointRule
  cattr_accessor :rules
  attr_accessor :context, :amount

  self.rules = []

  def self.find(context)
    rules.detect { |rule| rule.context == context }
  end

  def initialize(context, amount)
    @context, @amount = context, amount

    self.class.rules << self
  end
end
