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

  scope :chronological, -> { order('created_at ASC') }
  scope :reverse,       -> { order('created_at DESC') }
  scope :highest_first, -> { order('amount DESC') }
  scope :since,         ->(time) { for_timeframe time..Time.zone.now }
  scope :summary,       -> {
    select('user_type, user_id, SUM(amount) as amount').
    group('user_type, user_id')
  }

  def self.for_context(context)
    where context: context
  end

  def self.for_user(user)
    where user_id: user.id, user_type: user.class.name
  end

  def self.for_users(user_class, ids)
    where user_id: ids, user_type: user_class.name
  end

  def self.for_gameable(gameable)
    where gameable_id: gameable.id, gameable_type: gameable.class.name
  end

  def self.for_raw_gameable(gameable_type, gameable_id)
    where gameable_id: gameable_id, gameable_type: gameable_type
  end

  def self.for_timeframe(timeframe)
    where created_at: timeframe
  end

  def self.for_user_in_timeframe(context, user, timeframe)
    for_context(context).for_user(user).for_timeframe(timeframe)
  end
end
