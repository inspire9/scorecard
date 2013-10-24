class Post < ActiveRecord::Base
  belongs_to :user

  after_create lambda { |post|
    Scorecard::Points.score :new_post, gameable: post
  }
end
