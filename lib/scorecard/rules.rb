class Scorecard::Rules
  attr_reader :point_rules

  def initialize
    @point_rules = []
  end

  def add_rule(context, amount, options = {})
    point_rules << Scorecard::PointRule.new(context, amount, options)
  end

  def find_rule(context)
    point_rules.detect { |rule| rule.context == context }
  end

  def clear
    point_rules.clear
  end
end
