require 'spec_helper'

describe 'Unbadging' do
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
    Scorecard::Scorer.badge user: user
    post.destroy
  end

  it 'removes badges from users' do
    Scorecard::Scorer.badge user: user

    expect(card.badges.collect(&:name)).to be_empty
  end

  it "fires a badge notification when the badge is removed" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'unbadge.scorecard' do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      fired = (payload[:user] == user) && (payload[:badge] == :new_post)
    end

    Scorecard::Scorer.badge user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it 'removes badges when there were many and some are no longer valid' do
    Scorecard.badges.find(:new_post).gameables = lambda { |user|
      Post.where(user_id: user.id)
    }
    second = Post.create! user: user

    Scorecard::Scorer.badge user: user

    badge = card.badges.first
    expect(badge.name).to eq('Beginner')
    expect(badge.count).to eq(1)
    expect(badge.gameables).to eq([second])
  end

  it 'removes badges to users via Sidekiq' do
    Scorecard::Scorer.badge_async user: user

    expect(card.badges.collect(&:name)).to be_empty
  end
end
