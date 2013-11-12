require 'spec_helper'

describe 'Badges' do
  let(:user) { User.create! }
  let(:post) { Post.create! user: user }
  let(:card) { Scorecard::Card.new user }

  before :each do
    Scorecard.configure do |config|
      config.badges.add :new_post do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Write a post'
        badge.unlocked = 'You wrote a post!'
        badge.check    = lambda { |user| Post.where(user_id: user.id).any? }
      end
    end

    post
  end

  it 'assigns badges to users' do
    Scorecard::Scorer.badge user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end

  it "fires a badge notification when the badge is awarded" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      fired = (payload[:user] == user) && (payload[:badge].identifier == :new_post)
    end

    Scorecard::Scorer.badge user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it "doesn't repeat badges with different identifiers" do
    Scorecard::Scorer.badge user: user
    Scorecard::Scorer.badge user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end

  it "fires a badge notification only when the badge is awarded" do
    count = 0

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      count += 1
    end

    Scorecard::Scorer.badge user: user
    Scorecard::Scorer.badge user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(count).to eq(1)
  end

  it "repeats repeatable badges with different identifiers" do
    Scorecard.badges.find(:new_post).gameables = lambda { |user|
      Post.where(user_id: user.id)
    }
    second = Post.create! user: user

    Scorecard::Scorer.badge user: user

    badge = card.badges.first
    expect(badge.name).to eq('Beginner')
    expect(badge.count).to eq(2)
    expect(badge.gameables).to eq([post, second])
  end

  it "fires a badge notification each time it is awarded" do
    Scorecard.badges.find(:new_post).gameables = lambda { |user|
      Post.where(user_id: user.id)
    }
    Post.create! user: user

    count = 0

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      count += 1
    end

    Scorecard::Scorer.badge user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(count).to eq(2)
  end

  it 'assigns badges to users via Sidekiq' do
    Scorecard::Scorer.badge_async user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end
end
