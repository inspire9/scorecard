class Post < ActiveRecord::Base
  belongs_to :user

  after_create lambda { |post|
    Scorecard::Scorer.points :new_post, gameable: post
  }
end
