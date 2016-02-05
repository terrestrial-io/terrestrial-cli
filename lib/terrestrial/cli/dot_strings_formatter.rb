module Terrestrial
  module Cli
    class DotStringsFormatter

      def initialize(entries)
        @entries = entries
      end

      def format_foreign_translation
        result = []
        entries.each do |entry|
          # Just ID and string needed for translation
          # files. Extra metadata is found in Base.lproj.
          result << "\"#{entry.identifier}\"=\"#{entry.string}\";"
          result << ""
        end
        result.join("\n")
      end

      def format
        result = []
        entries.each do |entry|
          result.concat(file_comments(entry))
          result.concat(id_and_string(entry))
          result.concat(spacing) 
        end
        result.join("\n")
      end

      private

      def file_comments(entry)
        ["// Files:"] + 
          entry
            .occurences
            .uniq {|occ| occ.file }
            .map  {|occ| "// - #{occ.file}" }
      end

      def id_and_string(entry)
        ["\"#{entry.identifier}\"=\"#{entry.formatted_string}\";"]
      end

      def spacing
        [""] # No need to put new line because of join above
      end

      def entries
        @entries
      end
    end
  end
end
