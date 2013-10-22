require 'spec_helper'

describe 'Carmack' do
  it "stores points for configured behaviour" do
    Carmack::PointRule.new :new_post, 50

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
end
