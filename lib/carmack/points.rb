class Carmack::Points
  def self.score(context, options)
    ActiveSupport::Notifications.instrument 'points.carmack',
      options.merge(context: context)
  end

  def self.score_async(context, options)
    [:gameable, :user].each do |prefix|
      next unless options[prefix]

      options["#{prefix}_id"]   = options[prefix].id
      options["#{prefix}_type"] = options[prefix].class.name
      options.delete prefix
    end

    Carmack::Worker.perform_async context, options.stringify_keys
  end
end
