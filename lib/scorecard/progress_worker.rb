class Scorecard::ProgressWorker
  include Sidekiq::Worker

  def perform(identifier, options)
    Scorecard::Scorer.progress identifier.to_sym,
      Scorecard::Parameters.new(options).contract
  end
end
