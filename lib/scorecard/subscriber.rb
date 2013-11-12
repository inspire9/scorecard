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
    badge    = Scorecard.badges.find event.payload[:badge]
    existing = Scorecard::UserBadge.for badge.identifier, event.payload[:user]
    return unless existing.empty? || badge.repeatable?

    event.payload[:gameable]   ||= event.payload[:user]
    event.payload[:identifier] ||= event.payload[:gameable].id

    user_badge = Scorecard::UserBadge.create(
      event.payload.slice(:badge, :gameable, :user, :identifier)
    )
    ActiveSupport::Notifications.instrument(
      'badge.scorecard', user: event.payload[:user],
      badge: Scorecard::AppliedBadge.new(
        user_badge.badge.to_sym, user_badge.user
      ),
      gameable: event.payload[:gameable]
    ) if user_badge.persisted?
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
