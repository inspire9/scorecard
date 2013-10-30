class Scorecard::Parameters
  attr_reader :options, :prefixes

  def initialize(options, prefixes = [:gameable, :user])
    @options, @prefixes = options.clone, prefixes
  end

  def expand
    prefixes.collect(&:to_sym).each do |prefix|
      next unless options[prefix]

      options["#{prefix}_id"]   = options[prefix].id
      options["#{prefix}_type"] = options[prefix].class.name
      options.delete prefix
    end

    options.stringify_keys
  end

  def contract
    prefixes.collect(&:to_s).each do |prefix|
      next unless options["#{prefix}_type"]

      klass = options.delete("#{prefix}_type").constantize
      options[prefix] = klass.find options.delete("#{prefix}_id")
    end

    options.symbolize_keys
  end
end
