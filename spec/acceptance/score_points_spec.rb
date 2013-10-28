require 'spec_helper'

describe 'Scoring points' do
  it "stores points for configured behaviour" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50
    end

    user = User.create!
    post = Post.create! user: user

    Scorecard::Point.where(
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
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50,
        if: lambda { |payload| Post.count <= 1 }
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user

    Scorecard::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 1
  end

  it "does not double-up on points for the same event" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50
    end

    user = User.create!
    post = Post.create! user: user
    Scorecard::Scorer.points :new_post, gameable: post

    Scorecard::Point.where(
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
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50, limit: 100
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user
    post = Post.create! user: user

    Scorecard::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 2
  end

  it "respects timeframe options" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50, timeframe: :day
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user

    Scorecard::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 1
  end

  it "allows for processing via Sidekiq" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_user, 20
    end

    user = User.create!
    Scorecard::Scorer.points_async :new_user, gameable: user, user: user

    Scorecard::Point.where(
      context:       'new_user',
      amount:        20,
      identifier:    user.id.to_s,
      user_id:       user.id,
      user_type:     'User',
      gameable_id:   user.id,
      gameable_type: 'User'
    ).should_not be_empty
  end

  it "fires a generic notification" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_post, 50
    end

    fired = false
    user  = User.create!

    subscriber = ActiveSupport::Notifications.subscribe 'scorecard' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      fired = (event.payload[:user] == user)
    end

    post = Post.create! user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    fired.should be_true
  end
end
