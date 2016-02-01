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

      def inspect
        "<Terrestrial::Config config=#{values.inspect}>"
      end

      private

      def _load_project_config
        begin
          values.merge! _project_config
        rescue Errno::ENOENT
          abort "No terrerstrial.yaml found. Are you in the correct folder?"
        end
      end

      def _load_global_config
        values.merge! _global_config
      end

      def _reset!
        @values = Hash.new.merge(DEFAULTS)
      end

      def values
        @values ||= Hash.new.merge(DEFAULTS)
      end

      def _global_config
        YAML.load_file(Dir.home + "./terrestrial")
      end

      def _project_config
        YAML.load_file(Dir.pwd  + "/terrestrial.yml")
      end
    end
  end
end
