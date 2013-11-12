require 'spec_helper'

describe 'Unbadging' do
  let(:user) { User.create! }
  let(:card) { Scorecard::Card.new user }

  before :each do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    Scorecard::Scorer.badge :new_user, user: user
  end

  it 'removes badges from users' do
    Scorecard::Scorer.unbadge :new_user, user: user

    expect(card.badges.collect(&:name)).to be_empty
  end

  it "fires a badge notification when the badge is removed" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'unbadge.scorecard' do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      fired = (payload[:user] == user) && (payload[:badge] == :new_user)
    end

    Scorecard::Scorer.unbadge :new_user, user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it 'removes badges to users via Sidekiq' do
    Scorecard::Scorer.unbadge_async :new_user, user: user

    expect(card.badges.collect(&:name)).to be_empty
  end
end
