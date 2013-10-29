class Scorecard::Card
  attr_reader :user

  def initialize(user)
    @user = user
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
