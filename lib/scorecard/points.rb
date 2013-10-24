class Scorecard::Points
  def self.score(context, options)
    ActiveSupport::Notifications.instrument 'points.scorecard',
      options.merge(context: context)
  end

  def self.score_async(context, options)
    [:gameable, :user].each do |prefix|
      next unless options[prefix]

      options["#{prefix}_id"]   = options[prefix].id
      options["#{prefix}_type"] = options[prefix].class.name
      options.delete prefix
    end

    Scorecard::Worker.perform_async context, options.stringify_keys
  end
end
