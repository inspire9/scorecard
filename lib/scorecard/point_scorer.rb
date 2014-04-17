class Scorecard::PointScorer
  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    return if rule.nil?

    payload[:identifier] ||= payload[:gameable].id
    payload[:user]       ||= payload[:gameable].user
    payload[:amount]     ||= amount

    return unless allowed?

    instrument 'scorecard', user: payload[:user] if point.persisted?
  end

  private

  attr_reader :payload

  delegate :instrument, to: ActiveSupport::Notifications

  def allowed?
    rule.allowed? payload
  end

  def amount
    if rule.amount.respond_to?(:call)
      rule.amount.call payload
    else
      rule.amount
    end
  end

  def point
    Scorecard::Point.create(
      payload.slice(:context, :amount, :identifier, :user, :gameable)
    )
  end

  def rule
    @rule ||= Scorecard.rules.find payload[:context]
  end
end
