module Terrestrial
  module Cli
    class Init < Command

      def run
        check_arguments
      end

      private

      def check_arguments
        @api_key = opts[:api_key] || Config[:api_key] || abort("No api key provided for. You can find your API key at https://mission.terrestrial.io/.")
      end

      def api_key
        @api_key
      end
    end
  end
end
