require 'terrestrial/cli/flight/ios_workflow.rb'
require 'terrestrial/cli/flight/table_workflow.rb'
require 'terminal-table'
require 'pathname'

module Terrestrial
  module Cli
    class Flight < Command

      def run
        Config.load!

        if !Config.project_config_exist?
          abort_not_initialized
        end
        if Config[:translation_files].any?
          abort_already_run_flight
        end

        puts "- Finding untranslated human readable strings..."
        TerminalUI.show_spinner do
          find_new_strings
        end

        puts "------------------------------------"
        puts "- Found #{strings.count} strings"
        puts ""
        exclusions = TableWorkflow.new(strings).run
        puts "------------------------------------"
        puts "- Done!"

        strings.exclude_occurences(exclusions)

        if Config[:platform] == "ios"
          IosWorkflow.new(strings).run
        elsif Config[:platform] == 'android'
          android_workflow
        end
      end

      private

      def android_workflow
        puts "- Terrestrial will annotate the selected strings in your strings.xml file:"
        puts "-  e.g.  <string name='my_name'>My string!</string>  =>  <string terrestrial='true' name='my_name'>My string</string>"
      end


      def find_new_strings
        @strings = Bootstrapper.find_new_strings(Config[:directory])
      end

      def file_name_with_line_number(string)
        if string.line_number
          "#{string.file}:#{string.line_number}"
        else
          string.file
        end
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
        else 
          # TODO
        end
      end
    end
  end
end
