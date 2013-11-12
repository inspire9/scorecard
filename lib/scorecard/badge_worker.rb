class Scorecard::BadgeWorker
  include Sidekiq::Worker

  def perform(options)
    Scorecard::Scorer.badge Scorecard::Parameters.new(options).contract
  end
end
