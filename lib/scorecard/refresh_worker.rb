class Scorecard::RefreshWorker
  include Sidekiq::Worker
  sidekiq_options unique_for: 15.minutes

  def perform(options)
    Scorecard::Scorer.refresh Scorecard::Parameters.new(options).contract
  end
end
