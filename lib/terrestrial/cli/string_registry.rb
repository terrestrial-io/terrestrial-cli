module Terrestrial
  module Cli
    class StringRegistry

      def self.load
        entries = Config[:translation_files].flat_map do |file|
          begin
            DotStringsParser.parse_file(Config[:directory] + "/#{file}")
          rescue Errno::ENOENT
            abort "Could not find #{file}. If the file is no longer in your project, remove it from your tracked files in terrestrial.yml." 
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
    end
  end
end
