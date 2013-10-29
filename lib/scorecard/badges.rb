class Scorecard::Badges
  attr_reader :badges

  def initialize
    @badges = []
  end

  def add(identifier, &block)
    badges << Scorecard::Badge.new(identifier, &block)
  end

  def find(identifier)
    badges.detect { |badge| badge.identifier == identifier }
  end

  def clear
    badges.clear
  end
end
