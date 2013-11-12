class Scorecard::UnbadgeWorker
  include Sidekiq::Worker

  def perform(identifier, options)
    Scorecard::Scorer.unbadge identifier.to_sym,
      Scorecard::Parameters.new(options).contract
  end
end
