class Scorecard::ScoreWorker
  include Sidekiq::Worker

  def perform(context, options)
    Scorecard::Scorer.points context.to_sym,
      Scorecard::Parameters.new(options).contract
  end
end
