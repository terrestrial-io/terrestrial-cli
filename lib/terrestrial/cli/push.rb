module Terrestrial
  module Cli
    class Push < Command

      def run
        Config.load!
        load_string_registry

        web_client.push(Config[:project_id], Config[:app_id], format_entries)

        puts "Success!"
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
