class Carmack::Point < ActiveRecord::Base
  self.table_name = 'carmack_points'

  belongs_to :user,     polymorphic: true
  belongs_to :gameable, polymorphic: true
end
