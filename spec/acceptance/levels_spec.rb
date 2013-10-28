require 'spec_helper'

describe 'Levels' do
  let(:user) { User.create! email: 'pat-new' }

  before :each do
    Scorecard.configure do |config|
      config.levels = lambda { |user|
        user.email[/old/] ? 2 : 1
      }
    end
  end

  it "saves the score for the user" do
    Scorecard::Scorer.level user

    level = Scorecard::Level.where(user_id: user.id, user_type: 'User').first
    expect(level.amount).to eq(1)
  end

  it "fires a level notification when the level is first set" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'level.scorecard' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      fired = (event.payload[:user] == user)
    end

    Scorecard::Scorer.level user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it "fires a level notification when the level is changed" do
    Scorecard::Scorer.level user
    user.update_attributes(email: 'pat-old')

    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'level.scorecard' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      fired = (event.payload[:user] == user)
    end

    Scorecard::Scorer.level user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it "does not fire a notification when the level remains the same" do
    Scorecard::Scorer.level user

    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'level.scorecard' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      fired = (event.payload[:user] == user)
    end

    Scorecard::Scorer.level user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_false
  end

  it "retrieves stored level for a user" do
    Scorecard::Scorer.level user

    expect(Scorecard::Levels.for(user)).to eq(1)
  end
end
