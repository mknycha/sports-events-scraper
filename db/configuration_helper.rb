# frozen_string_literal: true

class ConfigurationHelper
  def establish_db_connection(env)
    ActiveRecord::Base.establish_connection(db_configuration[env])
  end

  private

  def db_configuration
    db_configuration_file = File.join(File.expand_path(__dir__), '..', 'db', 'config.yml')
    YAML.safe_load(File.read(db_configuration_file))
  end
end
