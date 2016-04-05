module Terrestrial
  module Cli
    class Photoshoot < Command

      def run
        Config.load!
        MixpanelClient.track("cli-photoshoot-command")
        @scheme = opts[:scheme]

        validate_inputs!
        print_progress_message

        TerminalUI.show_spinner do
          launcher = SimulatorLauncher.new(scheme: scheme, args: {
            'TerrestrialScreenShotMode' => true,
            'TerrestrialAPIToken' => Config[:api_key],
            'TerrestrialAppId' => Config[:app_id],
            'TerrestrialProjectId' => Config[:project_id],
            'TerrestrialURL' => Config[:api_url]
          })

          launcher.run
        end
      end

      private

      def scheme
        @scheme
      end

      def validate_inputs!
        if Config[:platform] != "ios"
          abort "Unfortunately photoshoot mode is only supported on iOS at this time."
        end
      end

      def print_progress_message
        if scheme
          puts "Starting simulator in photoshoot mode with scheme \"#{scheme}\"..."
        else
          puts "Starting simulator in photoshoot mode..."
        end
      end
    end
  end
end
