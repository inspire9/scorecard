require 'spec_helper'

describe 'Carmack' do
  before :each do
    Carmack.rules.clear
  end

  it "stores points for configured behaviour" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50
    end

    user = User.create!
    post = Post.create! user: user

    Carmack::Point.where(
      context:       'new_post',
      amount:        50,
      identifier:    post.id.to_s,
      user_id:       user.id,
      user_type:     'User',
      gameable_id:   post.id,
      gameable_type: 'Post'
    ).should_not be_empty
  end

  it "only stores points when provided logic passes" do
    Carmack.configure do |config|
      config.rules.add_rule_for_points :new_post, 50 do |payload|
        Post.count <= 1
      end
    end

    user = User.create!
    post = Post.create! user: user
    post = Post.create! user: user

    Carmack::Point.where(
      context: 'new_post',
      amount:  50
    ).count.should == 1
  end
end