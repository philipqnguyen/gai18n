# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'gai18n/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'gai18n'
  s.version     = GAI18n::VERSION
  s.authors     = ['Philip Q Nguyen']
  s.email       = ['supertaru@gmail.com']
  s.homepage    = 'https://github.com/philipqnguyen/gai18n'
  s.summary     = 'Generative AI for I18n'
  s.description = 'Use Generative AI to generate I18n translations.'
  s.metadata['allowed_push_host'] = 'https://rubygems.org'

  s.files = Dir['{lib,bin}/**/*', 'CHANGELOG.md', 'Rakefile', 'README.md', 'LICENSE.txt', 'CODE_OF_CONDUCT.md']
  s.executables = ['gai18n']

  s.required_ruby_version = '>= 3.0.0'

  s.add_dependency 'ruby-openai', '~> 6.2'
  s.add_dependency 'git', '~> 1.19'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake', '~> 13.1'
  s.add_development_dependency 'rspec', '~> 3.12'
  s.add_development_dependency 'webmock', '~> 3.19'
  s.add_development_dependency 'debug'
end
