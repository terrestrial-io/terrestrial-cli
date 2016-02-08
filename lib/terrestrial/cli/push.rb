module Terrestrial
  module Cli
    class Push < Command

      def run
        Config.load!
        MixpanelClient.track("cli-push-command")
        load_string_registry

        response = web_client.push(Config[:project_id], Config[:app_id], format_entries)

        if response.success?
          puts "Strings uploaded!"
        else
          puts "There was an error uploading your translations:"
          puts response.inspect
          puts "If the problem persists, contact us at team@terrestrial.io, or on Slack at https://terrestrial-slack.herokuapp.com/"
        end
      end

      private

      def format_entries
        string_registry.entries.map do |entry|
          {
            "string"     => entry["string"],
            "context"    => entry["context"],
            "identifier" => entry["identifier"]
          }
        end
      end

      def load_string_registry
        @string_registry = StringRegistry.load
      end

      def web_client
        @web_client ||= Web.new
      end

      def string_registry
        @string_registry
      end
    end
  end
end
