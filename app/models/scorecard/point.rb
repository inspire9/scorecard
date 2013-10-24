class Scorecard::Point < ActiveRecord::Base
  self.table_name = 'scorecard_points'

  belongs_to :user,     polymorphic: true
  belongs_to :gameable, polymorphic: true

  if Rails.version.to_s < '4.0.0'
    attr_accessible :context, :identifier, :amount, :gameable, :user
  end

  validates :context,    presence: true
  validates :identifier, presence: true, uniqueness: {
    scope: [:context, :user_type, :user_id]
  }
  validates :amount,     presence: true
  validates :user,       presence: true

  def self.for_context(context)
    where context: context
  end

  def self.for_user(user)
    where user_id: user.id, user_type: user.class.name
  end

  def self.for_user_in_timeframe(context, user, timeframe)
    for_context(context).for_user(user).where(created_at: timeframe)
  end
end
