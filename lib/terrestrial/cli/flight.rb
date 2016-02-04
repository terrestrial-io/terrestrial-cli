require 'terminal-table'

module Terrestrial
  module Cli
    class Flight < Command

      LOCAL_CONFIG = {
        strings_per_page: 10
      }

      def run
        Config.load!

        if !Config.project_config_exist?
          abort_not_initialized
        end
        if Config[:translation_files].any?
          abort_already_run_flight
        end
        puts "- Finding untranslated human readable strings..."
        show_wait_spinner do
          find_new_strings
        end

        puts "------------------------------------"
        puts "- Found #{strings.count} strings"
        puts ""
        print_strings_in_tables
        puts "------------------------------------"
        puts "- Done!"
        
        if Config[:platform] == "ios"
          ios_workflow
        elsif Config[:platform] == 'android'
          android_workflow
        end
      end

      private

      def android_workflow
        puts "- Terrestrial will annotate the selected strings in your strings.xml file:"
        puts "-  e.g.  <string name='my_name'>My string!</string>  =>  <string terrestrial='true' name='my_name'>My string</string>"
      end

      def ios_workflow
        puts "- Terrestrial will add #{strings.length - exclusions.length} strings to your base Localizable.strings."
        puts ""
        puts "------------------------------------"
        puts "-- Source Code" 
        puts "- Would you like Terrestrial to also modify the selected strings in your"
        puts "- source code to call .translated?"
        puts "-   e.g.  \"This is my string\"  =>  \"This is my string\".translated"
        puts ""
        puts "y/n?"

        command = STDIN.gets.chomp
        if command == "y"
          entries = strings.all_occurences.reject.with_index {|s, i| exclusions.include? i }

          show_wait_spinner do
            Editor.prepare_files(entries)
          end

          puts "- Done!"
        end
        puts "Totally creating the Localizable.strings files now..."
      end

      def print_strings_in_tables
        i = 0

        strings.all_occurences.each_slice(LOCAL_CONFIG[:strings_per_page]).with_index do |five_strings, index|
          puts "Page #{index + 1} of #{(strings.all_occurences.count / LOCAL_CONFIG[:strings_per_page].to_f).ceil}"

          table = create_string_table(five_strings, i)
          i += LOCAL_CONFIG[:strings_per_page]
          puts table
          puts table_instructions
          puts ""

          command = STDIN.gets.chomp
          if command == 'q'
            abort "Aborting..."
          else
            begin
              exclusions.concat(command.split(",").map(&:to_i))
            rescue
              abort "Couldn't process that command :( Aborting..."
            end
          end
        end
      end

      def create_string_table(strings, i)
        Terminal::Table.new(headings: ['Index', 'String', 'File']) do |t|
          strings.each_with_index do |string, tmp_index|
            t.add_row([i, string.string, file_name_with_line_number(string)])
            t.add_separator unless tmp_index == (strings.length - 1) || i == (strings.length - 1)
            i += 1
          end
        end
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

      def exclusions
        @exclusions ||= []
      end

      def show_wait_spinner(fps=10)
        chars = %w[| / - \\]
        delay = 1.0/fps
        iter = 0
        spinner = Thread.new do
          while iter do  # Keep spinning until told otherwise
            print chars[(iter+=1) % chars.length]
            sleep delay
            print "\b"
          end
        end
        yield.tap do     # After yielding to the block, save the return value
          iter = false   # Tell the thread to exit, cleaning up after itself…
          spinner.join   # …and wait for it to do so.
        end              # Use the block's return value as the method's
      end

      def table_instructions
        "-- Instructions --\n" +
        "- To exclude any strings from translation, type the index of each string.\n" +
        "-   e.g. 1,2,4\n" +
        "------------------\n" +
        "Any Exclusions? (press return to continue or 'q' to quit at any time)\n"
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
        end
      end
    end
  end
end
