require 'bundler'

Bundler.setup :default, :development

require 'combustion'
require 'carmack'

Combustion.initialize! :active_record

require 'rspec/rails'

Dir["./spec/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
