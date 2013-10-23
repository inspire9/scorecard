class Carmack::PointRule
  attr_accessor :context, :amount, :condition

  def initialize(context, amount, &condition)
    @context, @amount, @condition = context, amount, condition
  end

  def allowed?(payload)
    condition.nil? || condition.call(payload)
  end
end
