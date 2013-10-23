class Carmack::Worker
  include Sidekiq::Worker

  def perform(context, options)
    %w(gameable user).each do |prefix|
      next unless options["#{prefix}_type"]

      klass = options.delete("#{prefix}_type").constantize
      options[prefix] = klass.find options.delete("#{prefix}_id")
    end

    Carmack::Points.score context.to_sym, options.symbolize_keys
  end
end
