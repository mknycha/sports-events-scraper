class InitializerCommon
  def self.load_config_file_current_env(config_filename)
    project_root = File.dirname(__FILE__) + '/..'
    config_file = project_root + "/config/#{config_filename}.yml"
    loaded_config = YAML::load(ERB.new(IO.read(config_file)).result)
    loaded_config&.dig(ruby_env)
  end

  def self.ruby_env
    ENV['RUBY_ENV'] || 'development'
  end
end