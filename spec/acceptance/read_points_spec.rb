require 'spec_helper'

describe 'Reading points' do
  it "returns the total points for a user" do
    Scorecard.configure do |config|
      config.rules.add_rule :new_user, 20
      config.rules.add_rule :new_post, 30
    end

    user = User.create!
    post = Post.create! user: user
    Scorecard::Scorer.points :new_user, gameable: user, user: user

    Scorecard::Card.new(user).points.should == 50
  end
end
