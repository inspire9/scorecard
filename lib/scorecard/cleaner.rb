class Scorecard::Cleaner
  def self.points(gameable)
    Scorecard::Point.for_gameable(gameable).each do |point|
      point.destroy
      ActiveSupport::Notifications.instrument 'scorecard', user: point.user
    end
  end

  def self.points_async(gameable)
    Scorecard::ClearWorker.perform_in 10.seconds, gameable.class.name,
      gameable.id
  end
end
