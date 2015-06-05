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

    if points_changed?
      instrument 'scorecard', user: payload[:user], point: point
    end
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

  def existing_point?
    return @existing_point_exists unless @existing_point_exists.nil?

    @existing_point_exists = existing_point.present?
  end

  def existing_point
    @existing_point ||= Scorecard::Point.find_by(
      Scorecard::Parameters.new(
        payload.slice(:context, :identifier, :user, :gameable)
      ).expand
    )
  end

  def point
    return existing_point if existing_point?

    @point ||= Scorecard::Point.create(
      payload.slice(:context, :amount, :identifier, :user, :gameable)
    )
  end

  def points_changed?
    if existing_point?
      return false if existing_point.amount == payload[:amount]

      existing_point.amount = payload[:amount]
      existing_point.save
    else
      point.persisted?
    end
  end

  def rule
    @rule ||= Scorecard.rules.find payload[:context]
  end
end
