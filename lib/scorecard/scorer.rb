class Scorecard::Scorer
  def self.badge(identifier, options)
    ActiveSupport::Notifications.instrument 'badge.scorecard',
      options.merge(badge: identifier)
  end

  def self.level(user)
    level = Scorecard::Level.for_user(user) || Scorecard::Level.new(user: user)
    level.amount = Scorecard.levels.call user
    return unless level.amount_changed?

    level.save
    ActiveSupport::Notifications.instrument 'level.scorecard', user: user
  end

  def self.points(context, options)
    ActiveSupport::Notifications.instrument 'points.scorecard',
      options.merge(context: context)
  end

  def self.points_async(context, options)
    [:gameable, :user].each do |prefix|
      next unless options[prefix]

      options["#{prefix}_id"]   = options[prefix].id
      options["#{prefix}_type"] = options[prefix].class.name
      options.delete prefix
    end

    Scorecard::ScoreWorker.perform_async context, options.stringify_keys
  end
end
