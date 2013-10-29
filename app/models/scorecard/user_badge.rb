class Scorecard::UserBadge < ActiveRecord::Base
  self.table_name = 'scorecard_user_badges'

  belongs_to :user,     polymorphic: true
  belongs_to :gameable, polymorphic: true

  if Rails.version.to_s < '4.0.0'
    attr_accessible :badge, :identifier, :gameable, :user
  end

  validates :badge,      presence: true
  validates :identifier, presence: true, uniqueness: {
    scope: [:badge, :user_type, :user_id]
  }
  validates :user,       presence: true

  def self.for(badge, user)
    for_user(user).where badge: badge
  end

  def self.for_user(user)
    where user_id: user.id, user_type: user.class.name
  end

  def self.for_gameable(gameable)
    where gameable_id: gameable.id, gameable_type: gameable.class.name
  end
end
