require 'spec_helper'

describe 'Reading points' do
  before :each do
    Scorecard.configure do |config|
      config.rules.add :new_user, 20
      config.rules.add :new_post, 30
    end
  end

  it "returns the total points for a user" do
    user = User.create!
    post = Post.create! user: user
    Scorecard::Scorer.points :new_user, gameable: user, user: user

    expect(Scorecard::Card.new(user).points).to eq(50)
  end

  it 'returns leadership board' do
    user_a, user_b = User.create!, User.create!
    post = Post.create! user: user_a

    Scorecard::Scorer.points :new_user, gameable: user_a, user: user_a
    Scorecard::Scorer.points :new_user, gameable: user_b, user: user_b

    expect(Scorecard::Board.new.to_a).to eq([{user_a => 50}, {user_b => 20}])
  end

  it 'can limit leadership boards by users' do
    user_a, user_b, user_c = User.create!, User.create!, User.create!
    post = Post.create! user: user_b

    Scorecard::Scorer.points :new_user, gameable: user_a, user: user_a
    Scorecard::Scorer.points :new_user, gameable: user_b, user: user_b
    Scorecard::Scorer.points :new_user, gameable: user_c, user: user_c

    board = Scorecard::Board.new users: [User, [user_a.id, user_b.id]]

    expect(board.to_a).to eq([{user_b => 50}, {user_a => 20}])
  end

  it 'can limit points by timeframe' do
    user_a, user_b = User.create!, User.create!
    post = Post.create! user: user_b

    Scorecard::Scorer.points :new_user, gameable: user_a, user: user_a
    Scorecard::Scorer.points :new_user, gameable: user_b, user: user_b

    Scorecard::Point.where(user_id: user_b, context: 'new_user').update_all(
      created_at: 2.days.ago
    )

    board = Scorecard::Board.new since: 1.day.ago

    expect(board.to_a).to eq([{user_b => 30}, {user_a => 20}])
  end
end
