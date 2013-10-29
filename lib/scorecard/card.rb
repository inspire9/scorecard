class Scorecard::Card
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def badges
    @badges ||= begin
      identifiers = Scorecard::UserBadge.for_user(user).pluck(:badge).uniq
      identifiers.collect { |identifier|
        Scorecard::AppliedBadge.new identifier.to_sym, user
      }
    end
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
