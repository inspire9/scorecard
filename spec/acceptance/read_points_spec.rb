require 'spec_helper'

describe 'Reading points' do
  it "returns the total points for a user" do
    Scorecard.configure do |config|
      config.rules.add_rule_for_points :new_user, 20
      config.rules.add_rule_for_points :new_post, 30
    end

    user = User.create!
    post = Post.create! user: user
    Scorecard::Points.score :new_user, gameable: user, user: user

    Scorecard::Points.for(user).should == 50
  end
end
