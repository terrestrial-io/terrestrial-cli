module Terrestrial
  module Cli
    class StringRegistry

      def self.load
        entries = Config[:translation_files].flat_map do |file|
          begin
            entries = find_entries(file)
            entries.each do |entry|
              entry["file"] = file # Ensure paths are relative
            end
          rescue Errno::ENOENT
            puts ""
            puts "Could not find localization file."
            puts "Looked in #{Config[:directory] + "/" + file}"
            puts "If the file is no longer in your project, remove it from your tracked files in terrestrial.yml."
            abort
          end
        end

        new(entries)
      end

      def initialize(entries)
        @entries = entries
      end

      def entries
        @entries
      end

      def self.find_entries(file)
        if Config[:platform] == "ios"
          DotStringsParser.parse_file(Config[:directory] + "/#{file}")
        elsif Config[:platform] == "android"
          AndroidXmlParser.parse_file(Config[:directory] + "/#{file}")
        elsif Config[:platform] == "unity"
          UnityParser.parse_file(Config[:directory] + "/#{file}")
        end
      end
    end
  end
end
