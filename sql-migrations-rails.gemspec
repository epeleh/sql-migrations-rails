# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'sql/migrations/rails/version'

Gem::Specification.new do |spec|
  spec.name        = 'sql-migrations-rails'
  spec.version     = Sql::Migrations::Rails::VERSION
  spec.authors     = ['Evgeny Peleh']
  spec.email       = ['pelehev@gmail.com']
  spec.homepage    = 'https://github.com/epeleh/sql-migrations-rails'
  spec.summary     = 'Rails ActiveRecord plugin'
  spec.description = 'Rails plugin. Allows you to write plain SQL migrations without Ruby code.'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_dependency 'rails', '~> 5.2.2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'sqlite3'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
end
