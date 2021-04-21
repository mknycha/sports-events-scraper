# frozen_string_literal: true

Bundler.require
require_relative 'load_files'
require_relative 'mailer_initializer'

db_configuration = Database::ConfigurationHelper.db_configuration[ENV['RUBY_ENV']]
ActiveRecord::Base.establish_connection(db_configuration)

require 'resque'
require 'resque/tasks'

StandaloneMigrations::Tasks.load_tasks
