require 'spec_helper'

describe 'Carmack' do
  before :each do
    Carmack.rules.clear
  end

  it "stores points for configured behaviour" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50
    end

    user = User.create!
    post = Post.create! user: user

    Carmack::Point.where(
      context:       'new_post',
      amount:        50,
      identifier:    post.id.to_s,
      user_id:       user.id,
      user_type:     'User',
      gameable_id:   post.id,
      gameable_type: 'Post'
    ).should_not be_empty
  end

  it "only stores points when provided logic passes" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50,
        if: lambda { |payload| Post.count <= 1 }
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user

    Carmack::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 1
  end

  it "does not double-up on points for the same event" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50
    end

    user = User.create!
    post = Post.create! user: user
    Carmack::Points.score :new_post, gameable: post

    Carmack::Point.where(
      context:       'new_post',
      amount:        50,
      identifier:    post.id.to_s,
      user_id:       user.id,
      user_type:     'User',
      gameable_id:   post.id,
      gameable_type: 'Post'
    ).count.should == 1
  end

  it "respects limit options" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50, limit: 100
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user
    post = Post.create! user: user

    Carmack::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 2
  end

  it "respects timeframe options" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50, timeframe: :day
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user

    Carmack::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 1
  end

  it "allows for processing via Sidekiq" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_user, 20
    end

    user = User.create!
    Carmack::Points.score_async :new_user, gameable: user, user: user

    Carmack::Point.where(
      context:       'new_user',
      amount:        20,
      identifier:    user.id.to_s,
      user_id:       user.id,
      user_type:     'User',
      gameable_id:   user.id,
      gameable_type: 'User'
    ).should_not be_empty
  end
end
