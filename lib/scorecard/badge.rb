class Scorecard::Badge
  attr_reader :identifier
  attr_accessor :name, :locked, :unlocked, :check, :gameables

  def initialize(identifier, &block)
    @identifier = identifier

    block.call self
  end

  def repeatable?
    @gameables.present?
  end
end
