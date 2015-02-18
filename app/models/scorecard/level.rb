class Scorecard::Level < ActiveRecord::Base
  self.table_name = 'scorecard_levels'

  belongs_to :user, polymorphic: true

  if defined?(ProtectedAttributes) || !defined?(ActionController::StrongParameters)
    attr_accessible :amount, :user
  end

  validates :amount,  presence: true
  validates :user,    presence: true
  validates :user_id, uniqueness: {scope: :user_type}

  def self.for_user(user)
    where(user_id: user.id, user_type: user.class.name).first
  end
end
