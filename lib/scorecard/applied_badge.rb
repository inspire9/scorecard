class Scorecard::AppliedBadge
  attr_accessor :badge, :user

  delegate :name, :locked, :unlocked, :repeatable?, to: :badge

  def initialize(identifier, user)
    @user  = user
    @badge = Scorecard.badges.find identifier
  end

  def count
    Scorecard::UserBadge.for(badge.identifier, user).count
  end
end
