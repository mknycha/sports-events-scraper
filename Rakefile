# frozen_string_literal: true

Bundler.require
require_relative 'load_files'
require_relative 'mailer_initializer'

require 'resque'
require 'resque/tasks'

StandaloneMigrations::Tasks.load_tasks
