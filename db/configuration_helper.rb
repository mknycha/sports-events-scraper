# frozen_string_literal: true

module Database
  class ConfigurationHelper
    def self.db_configuration
      db_configuration_file = File.join(File.expand_path(__dir__), '..', 'db', 'config.yml')
      YAML.safe_load(File.read(db_configuration_file), [], [], true)
    end
  end
end
