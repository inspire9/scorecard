module Carmack
  def self.configure
    yield self
  end

  def self.rules
    @rules ||= Carmack::Rules.new
  end
end

require 'carmack/engine'
require 'carmack/points'
require 'carmack/point_rule'
require 'carmack/rules'
require 'carmack/subscriber'
