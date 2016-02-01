require 'yaml'

module Terrestrial
  module Config
    class << self

      DEFAULTS = {
        api_url: "https://mission.terrestrial.io"
      }

      GLOBAL_CONFIG_LOCATION  = Dir.home + "./terrestrial"
      PROJECT_CONFIG_LOCATION = Dir.pwd  + "/terrestrial.yml"

      def load(opts = {})
        values.merge!(opts)
      end

      def load!(opts = {})
        load(opts)
        _load_project_config
        _load_global_config
      end

      def [](key)
        values[key]
      end

      def reset!
        _reset!
      end

      private

      def _load_project_config
        begin
          values.merge!(YAML.load_file(_project_config_path))
        rescue Errno::ENOENT
          abort "No terrerstrial.yaml found. Are you in the correct folder?"
        end
      end

      def _load_global_config
        values.merge!(YAML.load_file(_global_config_path))
      end

      def _reset!
        @values = Hash.new.merge(DEFAULTS)
      end

      def values
        @values ||= Hash.new.merge(DEFAULTS)
      end

      def _global_config_path
        Dir.home + "./terrestrial"
      end

      def _project_config_path
        Dir.pwd  + "/terrestrial.yml"
      end
    end
  end
end
