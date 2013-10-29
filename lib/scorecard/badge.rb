class Scorecard::Badge
  attr_reader :identifier
  attr_accessor :name, :locked, :unlocked

  def initialize(identifier, &block)
    @identifier = identifier

    block.call self
  end
end
