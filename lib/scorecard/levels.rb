class Scorecard::Levels
  def self.for(user)
    level = Scorecard::Level.for_user(user)
    level.nil? ? Scorecard.levels.call(user) : level.amount
  end
end
