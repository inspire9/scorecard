require 'spec_helper'

describe 'Clearing Points' do
  let(:post) { Post.create! user: user }
  let(:user) { User.create! }

  before :each do
    Scorecard.configure do |config|
      config.rules.add :new_post, 50
    end

    post
  end

  it 'removes points for a given gameable object' do
    expect(Scorecard::Card.new(user).points).to eq(50)

    Scorecard::Cleaner.points(post)

    expect(Scorecard::Card.new(user).points).to eq(0)
  end

  it 'clears points via Sidekiq' do
    expect(Scorecard::Card.new(user).points).to eq(50)

    Scorecard::Cleaner.points_async(post)

    expect(Scorecard::Card.new(user).points).to eq(0)
  end

  it "fires a generic notification" do
    fired = false

    subscriber = ActiveSupport::Notifications.subscribe 'scorecard' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      fired = (event.payload[:user] == user)
    end

    Scorecard::Cleaner.points_async(post)

    ActiveSupport::Notifications.unsubscribe(subscriber)

    expect(fired).to be_true
  end
end

