class Scorecard::Subscriber
  def self.attach_to(suffix)
    subscriber = new
    subscriber.public_methods(false).each do |event|
      next if event.to_s == 'call'

      ActiveSupport::Notifications.subscribe "#{event}.#{suffix}", subscriber
    end
  end

  def call(message, *args)
    method = message.split('.').first
    send method, ActiveSupport::Notifications::Event.new(message, *args)
  end

  def points(event)
    rule = Scorecard.rules.find_rule_for_points event.payload[:context]

    event.payload[:amount]     ||= rule.amount
    event.payload[:identifier] ||= event.payload[:gameable].id
    event.payload[:user]       ||= event.payload[:gameable].user

    return unless rule && rule.allowed?(event.payload)

    point = Scorecard::Point.create(
      event.payload.slice(:context, :amount, :identifier, :user, :gameable)
    )
    ActiveSupport::Notifications.instrument(
      'scorecard', user: event.payload[:user]
    ) if point.persisted?
  end
end
