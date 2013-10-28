class Scorecard::Levels
  def self.calculate(user)
    Scorecard.levels.call(user)
  end

  def self.calculate_and_store(user)
    level = Scorecard::Level.for_user(user) || Scorecard::Level.new(user: user)
    level.amount = calculate user
    return unless level.amount_changed?

    level.save
    ActiveSupport::Notifications.instrument 'level.scorecard', user: user
  end
end
