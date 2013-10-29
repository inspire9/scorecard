class Scorecard::Card
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def badges
    @badges ||= Scorecard::UserBadge.for_user(user).collect { |user_badge|
      Scorecard.badges.find user_badge.badge.to_sym
    }
  end

  def level
    @level ||= begin
      record = Scorecard::Level.for_user(user)
      record.nil? ? Scorecard.levels.call(user) : record.amount
    end
  end

  def points
    @points ||= Scorecard::Point.for_user(user).sum(:amount)
  end
end
