class Scorecard::Cleaner
  def self.points(gameable_or_type, gameable_id = nil)
    points = gameable_id.nil? ?
      Scorecard::Point.for_gameable(gameable_or_type) :
      Scorecard::Point.for_raw_gameable(gameable_or_type, gameable_id)

    points.each do |point|
      point.destroy
      ActiveSupport::Notifications.instrument 'scorecard', user: point.user
    end
  end

  def self.points_async(gameable)
    Scorecard::ClearWorker.perform_in 10.seconds, gameable.class.name,
      gameable.id
  end
end
