project_root = File.dirname(__FILE__) + '/..'
ruby_env = ENV['RUBY_ENV'] || 'development'
config_file = project_root + '/config/resque.yml'

resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = resque_config[ruby_env]