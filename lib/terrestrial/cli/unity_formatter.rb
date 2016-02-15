module Terrestrial
  module Cli
    class UnityFormatter

      def initialize(entries)
        @formatter = AndroidXmlFormatter.new(entries)
      end

      def format_foreign_translation
        formatter.format_foreign_translation
      end

      private

      def formatter
        @formatter
      end
    end
  end
end
