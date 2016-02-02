require 'terrestrial/cli/parser/base_parser'
require 'terrestrial/cli/parser/objc'
require 'terrestrial/cli/parser/swift'
require 'terrestrial/cli/parser/storyboard'
require 'terrestrial/cli/parser/android_xml'
require 'terrestrial/cli/parser/string_analyser'

module Terrestrial
  module CLI
    module Parser

      def self.find_strings(file)
        EngineMapper.parser_for(File.extname(file)).find_strings(file)
      end

      def self.find_api_calls(file)
        EngineMapper.parser_for(File.extname(file)).find_api_calls(file)
      end

      def self.find_nslocalizedstrings(file)
        EngineMapper.parser_for(File.extname(file)).find_nslocalizedstrings(file)
      end
    end
  end
end
