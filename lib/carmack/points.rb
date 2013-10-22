class Carmack::Points
  def self.score(context, options)
    ActiveSupport::Notifications.instrument 'points.carmack',
      options.merge(context: context)
  end
end
