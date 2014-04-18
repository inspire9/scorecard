class Scorecard::PointScorer
  def self.call(payload)
    new(payload).call
  end

  def initialize(payload)
    @payload = payload
  end

  def call
    return if rule.nil?

    payload[:identifier] ||= payload[:gameable].id.to_s
    payload[:user]       ||= payload[:gameable].user
    payload[:amount]     ||= amount

    return unless allowed?

    instrument 'scorecard', user: payload[:user] if points_changed?
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

  def existing_point
    @existing_point ||= Scorecard::Point.where(
      Scorecard::Parameters.new(
        payload.slice(:context, :identifier, :user, :gameable)
      ).expand
    ).first
  end

  def points_changed?
    if existing_point.present?
      return false if existing_point.amount == payload[:amount]

      existing_point.amount = payload[:amount]
      existing_point.save
    else
      Scorecard::Point.create(
        payload.slice(:context, :amount, :identifier, :user, :gameable)
      ).persisted?
    end
  end

  def rule
    @rule ||= Scorecard.rules.find payload[:context]
  end
end
