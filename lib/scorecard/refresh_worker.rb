class Scorecard::RefreshWorker
  include Sidekiq::Worker

  def perform(options)
    Scorecard::Scorer.refresh Scorecard::Parameters.new(options).contract
  end
end
