class Scorecard::Scorer
  def self.badge(options)
    ActiveSupport::Notifications.instrument 'badge.internal.scorecard', options
  end

  def self.badge_async(options)
    Scorecard::BadgeWorker.perform_async(
      Scorecard::Parameters.new(options).expand
    )
  end

  def self.level(user)
    level = Scorecard::Level.for_user(user) || Scorecard::Level.new(user: user)
    level.amount = Scorecard.levels.call user
    return unless level.amount_changed?

    level.save
    ActiveSupport::Notifications.instrument 'level.scorecard', user: user
  end

  def self.points(context, options)
    ActiveSupport::Notifications.instrument 'points.internal.scorecard',
      options.merge(context: context)
  end

  def self.points_async(context, options)
    Scorecard::ScoreWorker.perform_async context,
      Scorecard::Parameters.new(options).expand
  end

  def self.progress(options)
    ActiveSupport::Notifications.instrument 'progress.internal.scorecard',
      options
  end

  def self.progress_async(options)
    Scorecard::ProgressWorker.perform_async(
      Scorecard::Parameters.new(options).expand
    )
  end
end
