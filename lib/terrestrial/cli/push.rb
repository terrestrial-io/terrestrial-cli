module Terrestrial
  module Cli
    class Push < Command

      def run
        Config.load!
        MixpanelClient.track("cli-push-command")
        load_string_registry

        if string_registry.entries.any?
          if duplicates.any?
            show_duplicate_error_message
          else
            do_push
          end
        else
          show_no_entries_error_message
        end
      end

      private

      def do_push
        response = web_client.push(Config[:project_id], Config[:app_id], format_entries)

        if response.success?
          puts "Strings uploaded!"
        else
          puts "There was an error uploading your translations:"
          puts response.inspect
          puts "If the problem persists, contact us at team@terrestrial.io, or on Slack at https://terrestrial-slack.herokuapp.com/"
        end
      end

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

      def duplicates
        @duplicates ||= string_registry
                          .entries.group_by {|e| e["identifier"] }
                          .select {|id, entries| entries.length > 1}
      end

      def show_duplicate_error_message
        puts "- Push Failed"
        puts "Terrestrial found some duplicate string identifiers:"
        duplicates.each do |identifier, entries|
          puts ""
          puts "  '#{identifier}' found in"
          entries.each_with_index do |entry, i|
            puts "    #{i + 1}.) #{entry["file"]}"
          end
        end
        puts ""
        puts "String identifiers must be unique in each push. Make sure you remove any duplicates."
        puts "If you are accidentally tracking you base language files as well as some foreign language files,"
        puts "make sure you only track the base language."
      end

      def show_no_entries_error_message
        puts "Terrestrial could not find any strings in your project."
        puts "Are you tracking the correct files in terrestrial.yml?"
        puts ""
        puts "For more information, you can find our documentation at http://docs.terrestrial.io/"
        puts "You can also jump on our Slack via https://terrestrial-slack.herokuapp.com/"
      end
    end
  end
end
