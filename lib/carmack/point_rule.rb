class Carmack::PointRule
  TIMESPANS = [:day, :week, :month, :year]

  attr_accessor :context, :amount, :options

  def initialize(context, amount, options = {})
    @context, @amount, @options = context, amount, options
  end

  def allowed?(payload)
    if limit
      return false unless current_points(payload).sum(:amount) < limit
    elsif timeframe
      return false unless current_points(payload).count.zero?
    end

    options[:if].nil? || options[:if].call(payload)
  end

  private

  def current_points(payload)
    if timeframe.nil?
      Carmack::Point.for_user(payload[:context], payload[:user])
    else
      Carmack::Point.for_user_in_timeframe(payload[:context], payload[:user], time_range)
    end
  end

  def limit
    options[:limit]
  end

  def timeframe
    options[:timeframe]
  end

  def time_range
    unless TIMESPANS.include? timeframe
      raise ArgumentError, "Unknown timeframe argument #{timeframe.inspect}"
    end

    now = Time.zone.now
    now.send("beginning_of_#{timeframe}")..now.send("end_of_#{timeframe}")
  end
end
