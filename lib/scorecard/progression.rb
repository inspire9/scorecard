class Scorecard::Progression
  attr_reader :identifier, :amount
  attr_accessor :link_text, :link_url

  def initialize(identifier, amount, &block)
    @identifier, @amount = identifier, amount

    block.call self
  end
end
