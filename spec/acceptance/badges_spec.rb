require 'spec_helper'

describe 'Badges' do
  let(:user) { User.create! }
  let(:card) { Scorecard::Card.new user }

  it 'assigns badges to users' do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    Scorecard::Scorer.badge :new_user, user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end

  it "fires a badge notification when the badge is awarded" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      fired = (payload[:user] == user) && (payload[:badge].identifier == :new_user)
    end

    Scorecard::Scorer.badge :new_user, user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it "doesn't repeat badges with different identifiers" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    Scorecard::Scorer.badge :new_user, user: user
    Scorecard::Scorer.badge :new_user, user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end

  it "fires a badge notification only when the badge is awarded" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    count = 0

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      count += 1
    end

    Scorecard::Scorer.badge :new_user, user: user
    Scorecard::Scorer.badge :new_user, user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(count).to eq(1)
  end

  it "doesn't repeat repeatable badges with the same identifier" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name       = 'Beginner'
        badge.locked     = 'Sign up'
        badge.unlocked   = 'You signed up!'
        badge.repeatable = true
      end
    end

    Scorecard::Scorer.badge :new_user, user: user
    Scorecard::Scorer.badge :new_user, user: user

    badge = card.badges.first
    expect(badge.name).to eq('Beginner')
    expect(badge.count).to eq(1)
  end

  it "repeats repeatable badges with different identifiers" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name       = 'Beginner'
        badge.locked     = 'Sign up'
        badge.unlocked   = 'You signed up!'
        badge.repeatable = true
      end
    end

    Scorecard::Scorer.badge :new_user, user: user, identifier: '1'
    Scorecard::Scorer.badge :new_user, user: user, identifier: '2'

    badge = card.badges.first
    expect(badge.name).to eq('Beginner')
    expect(badge.count).to eq(2)
  end

  it "fires a badge notification each time it is awarded" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name       = 'Beginner'
        badge.locked     = 'Sign up'
        badge.unlocked   = 'You signed up!'
        badge.repeatable = true
      end
    end

    count = 0

    subscriber = ActiveSupport::Notifications.subscribe 'badge.scorecard' do |*args|
      count += 1
    end

    Scorecard::Scorer.badge :new_user, user: user, identifier: '1'
    Scorecard::Scorer.badge :new_user, user: user, identifier: '2'

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(count).to eq(2)
  end

  it 'assigns badges to users via Sidekiq' do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    Scorecard::Scorer.badge_async :new_user, user: user

    expect(card.badges.collect(&:name)).to eq(['Beginner'])
  end
end
