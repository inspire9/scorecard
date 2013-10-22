class Carmack::Subscriber
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
    rule = Carmack::PointRule.find event.payload[:context]

    Carmack::Point.create(
      context:    rule.context,
      amount:     event.payload[:amount]     || rule.amount,
      identifier: event.payload[:identifier] || event.payload[:gameable].id,
      user:       event.payload[:user]       || event.payload[:gameable].user,
      gameable:   event.payload[:gameable]
    )
  end
end
