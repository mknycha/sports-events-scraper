require_relative 'initializer_common'

database_config = InitializerCommon.load_config_file_current_env('database')
ActiveRecord::Base.establish_connection(database_config)
