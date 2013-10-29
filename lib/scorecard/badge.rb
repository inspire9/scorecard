class Scorecard::Badge
  attr_reader :identifier
  attr_accessor :name, :locked, :unlocked
  attr_writer   :repeatable

  def initialize(identifier, &block)
    @identifier = identifier
    @repeatable = false

    block.call self
  end

  def repeatable?
    @repeatable
  end
end
