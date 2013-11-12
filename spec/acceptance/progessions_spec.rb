require 'spec_helper'

describe 'Progressions' do
  let(:user) { User.create! }
  let(:card) { Scorecard::Card.new user }

  before :each do
    Scorecard.configure do |config|
      config.progressions.add :add_info, 10 do |progression|
        progression.link_text = 'Add some information'
        progression.link_url  = '/foo'
      end
    end
  end

  it 'marks progress for users' do
    Scorecard::Scorer.progress :add_info, user: user

    expect(card.progress).to eq(10)
  end

  it "fires a notification when progress is made" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'progress.scorecard' do |*args|
      payload = ActiveSupport::Notifications::Event.new(*args).payload
      fired = (payload[:user] == user)
    end

    Scorecard::Scorer.progress :add_info, user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end

  it "doesn't duplicate progress" do
    Scorecard::Scorer.progress :add_info, user: user
    Scorecard::Scorer.progress :add_info, user: user

    expect(card.progress).to eq(10)
  end

  it "fires only a single notification when progress is made" do
    count = 0

    subscriber = ActiveSupport::Notifications.subscribe 'progress.scorecard' do |*args|
      count += 1
    end

    Scorecard::Scorer.progress :add_info, user: user
    Scorecard::Scorer.progress :add_info, user: user

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(count).to eq(1)
  end

  it 'marks progress for users via Sidekiq' do
    Scorecard::Scorer.progress_async :add_info, user: user

    expect(card.progress).to eq(10)
  end
end
