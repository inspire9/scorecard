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

    Scorecard::Scorer.badge :new_user, user

    card.badges.collect(&:name).should == ['Beginner']
  end

  it "doesn't repeat badges" do
    Scorecard.configure do |config|
      config.badges.add :new_user do |badge|
        badge.name     = 'Beginner'
        badge.locked   = 'Sign up'
        badge.unlocked = 'You signed up!'
      end
    end

    Scorecard::Scorer.badge :new_user, user
    Scorecard::Scorer.badge :new_user, user

    card.badges.collect(&:name).should == ['Beginner']
  end
end
