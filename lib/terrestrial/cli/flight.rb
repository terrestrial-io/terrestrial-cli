require 'terrestrial/cli/flight/ios_workflow.rb'
require 'terrestrial/cli/flight/table_workflow.rb'
require 'terminal-table'
require 'pathname'

module Terrestrial
  module Cli
    class Flight < Command

      def run
        Config.load!
        MixpanelClient.track("cli-flight-command")

        if !Config.project_config_exist?
          abort_not_initialized
        end
        if Config[:translation_files].any?
          abort_already_run_flight
        end
        if Config[:platform] != "ios"
          puts "'flight' is not supported on Android."
          puts "  iOS projects often just include strings in their source code instead of extracting them into resource files."
          puts "  We created 'flight' to get iOS project up and running quicker."
          puts "  'R.string' makes localization much easier :)"
          abort 
        end

        puts "- Finding untranslated human readable strings..."
        TerminalUI.show_spinner do
          find_new_strings
        end

        puts "------------------------------------"
        puts "- Found #{strings.all_occurences.count} strings"
        puts ""
        exclusions = TableWorkflow.new(strings).run
        strings.exclude_occurences(exclusions)

        puts "------------------------------------"
        puts "- Done!"
        puts "- Terrestrial will add #{strings.all_occurences.count} strings to your base Localizable.strings."
        puts ""

        IosWorkflow.new(strings).run
      end

      private

      def find_new_strings
        @strings = Bootstrapper.find_new_strings(Config[:directory])
      end

      def strings
        @strings
      end

      def abort_not_initialized
        puts "You should initialize your project before running flight."
        puts "It's simple! You can do this by running:"
        puts ""
        puts "  terrestrial init --api-key <API KEY> --project-id <PROJECT ID>"
        puts ""
        puts "You can find your Api Key and Project ID at https://mission.terrestrial.io"
        abort
      end

      def abort_already_run_flight
        if Config[:platform] == "ios"
          puts "Looks like you already have Localizable.strings files."
          puts "'flight' scans your source code for human readable strings that have not been translated"
          puts "and helps you quickstart your internaionalization process."
          puts ""
          puts "If you want to new strings into your .strings file, run 'terrestrial gen'. It will:"
          puts "  1. Scan your source code for .translated and NSLocalizedString calls."
          puts "  2. Determine if the strings already exist in Localizable.strings."
          puts "  3. Append any new strings to your base Localizable.strings."
          puts ""
          puts "For more information, visit http://docs.terrestrial.io/, or jump on our Slack via https://terrestrial-slack.herokuapp.com/"
          abort
        end
      end
    end
  end
end
