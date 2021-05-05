require_relative 'initializer_common'

resque_config = InitializerCommon.load_config_file_current_env('resque')
Resque.redis = resque_config