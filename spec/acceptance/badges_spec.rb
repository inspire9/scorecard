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
