class Scorecard::ScoreWorker
  include Sidekiq::Worker

  def perform(context, options)
    Scorecard::Scorer.points context.to_sym,
      Scorecard::Parameters.new(options).contract
  rescue ActiveRecord::RecordNotFound
    # Record does not exist. No point scoring it.
  end
end
