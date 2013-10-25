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

    Scorecard::ScoreWorker.perform_async context, options.stringify_keys
  end

  def self.for(user)
    Scorecard::Point.for_user(user).sum(:amount)
  end

  def self.clear(gameable)
    Scorecard::Point.for_gameable(gameable).each &:destroy
  end

  def self.clear_async(gameable)
    Scorecard::ClearWorker.perform_async gameable.class.name, gameable.id
  end
end
