module Terrestrial
  module Config
    class << self

      DEFAULTS = {
        api_url: "https://mission.terrestrial.io",
        directory: Dir.pwd
      }

      GLOBAL_KEYS = [
        :api_key,
        :user_id
      ]

      PROJECT_KEYS = [
        :app_id,
        :project_id,
        :platform,
        :translation_files
      ]

      def load(opts = {})
        values.merge!(opts)
      end

      def load!(opts = {}, project: true, global: true)
        load(opts)
        _load_project_config if project
        _load_global_config if global
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

      def project_config_exist?
        File.exists?(_project_config_path)
      end

      def update_project_config(fail_if_exists: false)
        YamlHelper.update(_project_config_path, values.select {|key, val| PROJECT_KEYS.include? key })
      end

      def update_global_config
        YamlHelper.update(_global_config_path, values.select {|key, val| GLOBAL_KEYS.include? key })
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
        YamlHelper.read _global_config_path
      end

      def _project_config
        YamlHelper.read _project_config_path
      end

      def _global_config_path
        Dir.home + "/.terrestrial"
      end

      def _project_config_path
        Dir.pwd  + "/terrestrial.yml"
      end
    end
  end
end
