module Terrestrial
  module Cli
    class Scan < Command

      def run
        Config.load!

        @string_registry = StringRegistry.load
        @remote_registry = fetch_current_strings_from_web
      end

      private

      def fetch_current_strings_from_web
        web_client.get_app_strings(Config[:project_id], Config[:app_id]).body["data"]["strings"]
      end

      def web_client
        @web_client ||= Web.new
      end
    end
  end
end
