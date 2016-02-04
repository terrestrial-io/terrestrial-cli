module Terrestrial
  module Cli
    class VariableNormalizer

      def self.run(string, swift: false)
        result = string
        result = format_swift_string(result) if swift
        result = format_string(result)
      end

      def self.format_swift_string(target_string)
        formatted_string = target_string
        regex = /\\\(.*?\)/
        index = 1
        while formatted_string.scan(regex).any?
          formatted_string = formatted_string.sub(regex, "%#{index}$@")
          index += 1
        end
        formatted_string
      end

      def self.format_string(target_string)
        formatted_string = target_string
        regex = /\%@/
        index = 1
        while formatted_string.scan(regex).any?
          formatted_string = formatted_string.sub(regex, "%#{index}$@")
          index += 1
        end
        formatted_string
      end
    end
  end
end
