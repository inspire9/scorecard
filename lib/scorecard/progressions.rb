class Scorecard::Progressions
  include Enumerable

  attr_reader :progressions

  def initialize
    @progressions = []
  end

  def add(identifier, amount, &block)
    progressions << Scorecard::Progression.new(identifier, amount, &block)
  end

  def each(&block)
    progressions.each &block
  end

  def find(identifier)
    progressions.detect { |progression| progression.identifier == identifier }
  end

  def without(identifiers)
    progressions.reject { |progression|
      identifiers.include?(progression.identifier)
    }
  end

  def clear
    progressions.clear
  end
end
