class Scorecard::Progress < ActiveRecord::Base
  self.table_name = 'scorecard_progresses'

  belongs_to :user,     polymorphic: true

  if defined?(ProtectedAttributes) || !defined?(ActionController::StrongParameters)
    attr_accessible :identifier, :user
  end

  validates :identifier, presence: true, uniqueness: {
    scope: [:user_type, :user_id]
  }
  validates :user,       presence: true

  delegate :amount, to: :progression

  def self.for_user(user)
    where user_id: user.id, user_type: user.class.name
  end

  def self.for_identifier(identifier)
    where identifier: identifier.to_s
  end

  def progression
    Scorecard.progressions.find identifier.to_sym
  end
end
