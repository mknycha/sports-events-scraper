# frozen_string_literal: true

class ConfigurationHelper
  def self.establish_db_connection(env)
    ActiveRecord::Base.establish_connection(db_configuration[env])
  end

  def self.db_configuration
    db_configuration_file = File.join(File.expand_path(__dir__), '..', 'db', 'config.yml')
    YAML.safe_load(File.read(db_configuration_file), [], [], true)
  end

  private_class_method :db_configuration
end
