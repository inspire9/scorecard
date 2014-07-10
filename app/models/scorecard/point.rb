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
  scope :since,         ->(time) {
    where "scorecard_points.created_at > ?", time
  }
  scope :within,        ->(range) { where created_at: range }
  scope :summary_with,  ->(model) {
    group("#{model.table_name}.id").select <<-SQL
'#{model.name}'::varchar AS user_type,
#{model.table_name}.id   AS user_id,
COALESCE(SUM(amount), 0) AS amount
    SQL
  }
  scope :join_against,  ->(model) {
    joins <<-SQL
RIGHT OUTER JOIN #{model.table_name}
ON    scorecard_points.user_type = '#{model.name}'
  AND scorecard_points.user_id   = #{model.table_name}.id
    SQL
  }

  def self.for_context(context)
    where context: context
  end

  def self.for_user(user)
    where user_id: user.id, user_type: user.class.name
  end

  def self.for_user_ids(klass, ids)
    where user_id: ids, user_type: klass.name
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
