module Scorecard
  mattr_accessor :levels

  def self.configure
    yield self
  end

  def self.badges
    @badges ||= Scorecard::Badges.new
  end

  def self.rules
    @rules ||= Scorecard::Rules.new
  end
end

require 'scorecard/badge'
require 'scorecard/badges'
require 'scorecard/card'
require 'scorecard/cleaner'
require 'scorecard/engine'
require 'scorecard/point_rule'
require 'scorecard/rules'
require 'scorecard/scorer'
require 'scorecard/subscriber'

if defined?(Sidekiq)
  require 'scorecard/clear_worker'
  require 'scorecard/score_worker'
end
