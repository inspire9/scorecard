# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'scorecard'
  spec.version       = '0.0.1'
  spec.authors       = ['Pat Allan']
  spec.email         = ['pat@freelancing-gods.com']
  spec.summary       = 'Rails Engine for common scorecard patterns'
  spec.description   = 'Use an engine to track points, badges and levels in your Rails app.'
  spec.homepage      = 'https://github.com/inspire9/scorecard'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rails', '>= 3.2'

  spec.add_development_dependency 'combustion',  '~> 0.5.1'
  spec.add_development_dependency 'rspec-rails', '~> 2.14.0'
  spec.add_development_dependency 'sidekiq',     '~> 2.15'
  spec.add_development_dependency 'sqlite3',     '~> 1.3.8'
end
