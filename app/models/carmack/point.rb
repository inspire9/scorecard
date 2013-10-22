class Carmack::Point < ActiveRecord::Base
  self.table_name = 'carmack_points'

  belongs_to :user,     polymorphic: true
  belongs_to :gameable, polymorphic: true

  validates :context,    presence: true
  validates :identifier, presence: true
  validates :amount,     presence: true
  validates :user,       presence: true
end
