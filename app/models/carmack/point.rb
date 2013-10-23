class Carmack::Point < ActiveRecord::Base
  self.table_name = 'carmack_points'

  belongs_to :user,     polymorphic: true
  belongs_to :gameable, polymorphic: true

  validates :context,    presence: true
  validates :identifier, presence: true, uniqueness: {
    scope: [:context, :user_type, :user_id]
  }
  validates :amount,     presence: true
  validates :user,       presence: true

  def self.for_user(context, user)
    where(
      context:   context,
      user_id:   user.id,
      user_type: user.class.name
    )
  end

  def self.for_user_in_timeframe(context, user, timeframe)
    for_user(context, user).where(created_at: timeframe)
  end
end
