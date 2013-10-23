class Carmack::Rules
  attr_reader :point_rules

  def initialize
    @point_rules = []
  end

  def add_rule_for_points(context, amount, options = {})
    point_rules << Carmack::PointRule.new(context, amount, options)
  end

  def find_rule_for_points(context)
    point_rules.detect { |rule| rule.context == context }
  end

  def clear
    point_rules.clear
  end
end
