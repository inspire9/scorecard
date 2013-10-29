require 'bundler'

Bundler.setup :default, :development

require 'combustion'
require 'sidekiq'
require 'sidekiq/testing/inline'
require 'scorecard'

Combustion.initialize! :active_record

require 'rspec/rails'

Dir["./spec/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.before :each do
    Scorecard.rules.clear
    Scorecard.badges.clear
  end
end
