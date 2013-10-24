module Scorecard
  def self.configure
    yield self
  end

  def self.rules
    @rules ||= Scorecard::Rules.new
  end
end

require 'scorecard/engine'
require 'scorecard/points'
require 'scorecard/point_rule'
require 'scorecard/rules'
require 'scorecard/subscriber'
require 'scorecard/worker' if defined?(Sidekiq)
