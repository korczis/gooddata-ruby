require 'yaml'

module ConfigHelper
  DEFAULT_ENVIRONMENT = ENV['GD_GEM_ENV'] || :staging

  class << self
    def config(env = DEFAULT_ENVIRONMENT)
      unless @config
        path = File.join(File.dirname(__FILE__), '..', 'config/config.yml')
        @raw_config = YAML.load_file(path).symbolize_keys
        @config = @raw_config[:global].symbolize_keys
        @config.merge!(@raw_config[env].symbolize_keys) if env && @raw_config[env]
      end
      @config
    end
  end
end
