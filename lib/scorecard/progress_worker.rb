class Scorecard::ProgressWorker
  include Sidekiq::Worker

  def perform(options)
    Scorecard::Scorer.progress Scorecard::Parameters.new(options).contract
  end
end
