module Terrestrial
  module Cli
    class DotStringsFormatter

      def initialize(entries)
        @entries = entries
      end

      def format_foreign_translation
        result = []
        entries.reject(&:placeholder?).each do |entry|
          # just id and string needed for translation
          # files. extra metadata is found in base.lproj.
          result << id_and_string(entry)
          result << ""
        end

        result.concat(placeholder_disclaimer)

        entries.select(&:placeholder?).each do |entry|
          # just id and string needed for translation
          # files. extra metadata is found in base.lproj.
          result << id_and_string(entry)
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

      def placeholder_disclaimer
        [
          "// The following translations have been copied from the project base language because no translation was provided for them.",
          "// iOS requires each Localizable.strings file to contain all keys used in the project. In order to provide proper fallbacks, Terrestrial includes missing translations in each translation resource file.", 
          ""
        ]
      end

      def file_comments(entry)
        ["// Files:"] + 
          entry
            .occurences
            .uniq {|occ| occ.file }
            .map  {|occ| "// - #{occ.file}" }
      end

      def id_and_string(entry)
        if entry.respond_to? :formatted_string
          ["\"#{entry.identifier}\"=\"#{escape_string(entry.formatted_string)}\";"]
        else
          ["\"#{entry.identifier}\"=\"#{escape_string(entry.string)}\";"]
        end
      end

      def escape_string(string)
        string.gsub("\"", "\\\"")
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
