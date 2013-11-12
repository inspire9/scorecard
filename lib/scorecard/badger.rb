class Scorecard::Badger
  def self.update(user)
    Scorecard.badges.each do |badge|
      new(user, badge).update
    end
  end

  def initialize(user, badge)
    @user, @badge = user, badge
  end

  def update
    if badge.check.call user
      return unless existing.empty? || badge.repeatable?

      remove_old
      add_new
    else
      remove_all
    end
  end

  private

  attr_reader :user, :badge

  def add_new
    new_gameables.each do |gameable|
      user_badge = Scorecard::UserBadge.create(
        badge:      badge.identifier,
        gameable:   gameable,
        user:       user,
        identifier: gameable.id
      )

      ActiveSupport::Notifications.instrument(
        'badge.scorecard', user: user,
        badge: Scorecard::AppliedBadge.new(badge.identifier, user),
        gameable: gameable
      ) if user_badge.persisted?
    end
  end

  def existing
    @existing ||= Scorecard::UserBadge.for badge.identifier, user
  end

  def gameables
    @gameables ||= badge.repeatable? ? badge.gameables.call(user) : [user]
  end

  def new_gameables
    gameables.reject { |gameable|
      existing.any? { |existing| existing.gameable == gameable }
    }
  end

  def old_user_badges
    existing.reject { |user_badge|
      gameables.any? { |gameable| user_badge.gameable == gameable }
    }
  end

  def remove(user_badge)
    user_badge.destroy

    ActiveSupport::Notifications.instrument 'unbadge.scorecard',
      user: user, badge: badge.identifier, gameable: user_badge.gameable
  end

  def remove_all
    existing.each { |user_badge| remove user_badge }
  end

  def remove_old
    old_user_badges.each { |user_badge| remove user_badge }
  end
end
