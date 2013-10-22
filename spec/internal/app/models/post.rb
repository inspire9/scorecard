class Post < ActiveRecord::Base
  belongs_to :user

  after_create lambda { |post|
    Carmack::Points.score :new_post, gameable: post
  }
end
