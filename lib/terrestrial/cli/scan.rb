require 'terminal-table'

module Terrestrial
  module Cli
    class Scan < Command

      def run
        Config.load!
        MixpanelClient.track("cli-scan-command")

        TerminalUI.show_spinner do
          @string_registry = StringRegistry.load
          @remote_registry = fetch_current_strings_from_web
        end

        print_results
      end

      private

      def print_results
        puts "New Strings: #{new_strings.count}"
        puts "Removed Strings: #{removed_strings.count}"

        if opts[:verbose]
          print_diff
        else
          if rand(10) == 1 # Show hint ~10% of the time
            puts "(Hint: add --verbose to the 'scan' command to view the diff of local and remote strings.)"
          end
        end
      end

      def print_diff
        puts "--- Diff"
        puts "- New Strings"
        print_table(new_strings)
        puts ""
        puts "- Removed Strings"
        print_table(removed_strings)
      end

      def print_table(strings)
        puts Terminal::Table.new(headings: ['Identifier', 'String', 'Comment']) do |t|
          size = strings.count
          strings.each_with_index do |string, i|
            t.add_row([string["identifier"], string["string"], string["context"]])
            t.add_separator unless i == (size - 1)
          end
        end
      end

      def new_strings
        EntryCollectionDiffer.additions(@remote_registry, @string_registry.entries)
      end

      def removed_strings
        EntryCollectionDiffer.omissions(@remote_registry, @string_registry.entries)
      end

      def fetch_current_strings_from_web
        web_client.get_app_strings(Config[:project_id], Config[:app_id]).body["data"]["strings"]
      end

      def web_client
        @web_client ||= Web.new
      end
    end
  end
end
