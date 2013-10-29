class Scorecard::Points
  def self.clear(gameable)
    Scorecard::Point.for_gameable(gameable).each do |point|
      point.destroy
      ActiveSupport::Notifications.instrument 'scorecard', user: point.user
    end
  end

  def self.clear_async(gameable)
    Scorecard::ClearWorker.perform_in 10.seconds, gameable.class.name,
      gameable.id
  end
end
