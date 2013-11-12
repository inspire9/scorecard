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

  def badge(event)
    Scorecard::Badger.update event.payload[:user]
  end

  def points(event)
    rule = Scorecard.rules.find event.payload[:context]
    return if rule.nil?

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

  def progress(event)
    Scorecard.progressions.each do |progression|
      if progression.check.call event.payload[:user]
        progress = Scorecard::Progress.create(
          user: event.payload[:user], identifier: progression.identifier
        )

        ActiveSupport::Notifications.instrument(
          'progress.scorecard', user: event.payload[:user]
        ) if progress.persisted?
      else
        progresses = Scorecard::Progress.for_user(event.payload[:user]).
          for_identifier(progression.identifier)
        progresses.each &:destroy

        ActiveSupport::Notifications.instrument(
          'progress.scorecard', user: event.payload[:user]
        ) if progresses.any?
      end
    end
  end
end
