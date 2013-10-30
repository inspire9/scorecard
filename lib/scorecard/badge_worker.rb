class Scorecard::BadgeWorker
  include Sidekiq::Worker

  def perform(identifier, options)
    Scorecard::Scorer.badge identifier.to_sym,
      Scorecard::Parameters.new(options).contract
  end
end
