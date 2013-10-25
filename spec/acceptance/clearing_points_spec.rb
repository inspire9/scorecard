require 'spec_helper'

describe 'Clearing Points' do
  let(:post) { Post.create! user: user }
  let(:user) { User.create! }

  before :each do
    Scorecard.configure do |config|
      config.rules.add_rule_for_points :new_post, 50
    end

    post
  end

  it 'removes points for a given gameable object' do
    Scorecard::Points.for(user).should == 50

    Scorecard::Points.clear(post)

    Scorecard::Points.for(user).should == 0
  end

  it 'clears points via Sidekiq' do
    Scorecard::Points.for(user).should == 50

    Scorecard::Points.clear_async(post)

    Scorecard::Points.for(user).should == 0
  end
end

