module Terrestrial
  module Cli
    class Init < Command

      def run
        # Fail early if project already exists
        Terrestrial::Config.update_project_config(fail_if_exists: true)

        check_arguments
        detect_platform
        create_app_in_web
        update_config
      end

      private

      def update_config
        Terrestrial::Config.load({
          app_id: @response.body["data"]["id"],
          project_id: @project_id,
          platform: @platform,
          api_key: @api_key
        })

        Terrestrial::Config.update_global_config
        Terrestrial::Config.update_project_config
      end

      def create_app_in_web
        @client = Terrestrial::Web.new(@api_key)
        @response = @client.create_app(@project_id, @platform)
      end

      def check_arguments
        @api_key = opts[:api_key] || Config[:api_key] || 
                 abort("No api key provided. You can find your API key at https://mission.terrestrial.io/.")

        @project_id = opts.fetch(:project_id) { abort(
          "No project ID provided. Terrestrial needs to know which project this app belongs to.\n" +
          "Visit https://mission.terrestrial.io to find your project ID."
        )}
      end

      def detect_platform
        @platform = DetectsProjectType.run
      end

      def project_id
        @project_id
      end

      def api_key
        @api_key
      end
    end
  end
end
