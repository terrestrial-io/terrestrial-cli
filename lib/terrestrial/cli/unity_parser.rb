module Terrestrial
  module Cli
    class UnityParser

      def self.parse_file(file)
        # Same file format as Android, so we delegate directly.
        result = AndroidXmlParser.parse_file(file)

        # Map over the results to change the types
        # to be unity instead of the Android default.
        result.map do |entry|
          entry["type"] = "unity"
          entry
        end
      end
    end
  end
end
