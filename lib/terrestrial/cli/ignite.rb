module Terrestrial
  module Cli
    class Ignite < Command

      WORKING_DIR = '/usr/local/var/terrestrial'

      def run
        Config.load!
        MixpanelClient.track("cli-ignite-command")
        @lang   = opts[:language]
        @scheme = opts[:scheme]

        validate_inputs!
        print_progress_message

        TerminalUI.show_spinner do
          launcher = SimulatorLauncher.new(scheme: scheme, args: {
            'AppleLanguages' => "(#{lang})",
          })

          launcher.run
        end
      end

      private

      def lang
        @lang
      end

      def scheme
        @scheme
      end

      def validate_inputs!
        if Config[:platform] != "ios"
          abort "Unfortunately launching your app in a locale via 'ignite' is only supported on iOS at this time."
        end

        if lang.nil? || lang.empty?
          abort "Please provide a locale to launch the simulator in.\n  e.g. 'terrestrial ignite es'"
        end
      end

      def print_progress_message
        if scheme
          puts "Starting simulator in locale \"#{lang}\" with scheme \"#{scheme}\"..."
        else
          puts "Starting simulator in locale \"#{lang}\"..."
        end
      end

      def ensure_var_folder_exists
        `mkdir -p #{WORKING_DIR}`
      end
    end
  end
end
