module Terrestrial
  module CLI
    module Parser
      class BaseParser

        # Interface for finding locations in files where the Terrestrial
        # API will be accessing strings
        #
        #   file - path to source file
        #
        #   Expected to return an array of
        #   Bootstrapper::NewStringEntry
        #   objects
        def self.find_api_calls(file)
          raise "Not implemented"
        end

        # Interface for finding strings in a source file
        #
        #   file - path to source file
        #
        #   Expected to return an array of
        #   hashes TODO: make return an object
        def self.find_string(file)
          raise "Not implemented"
        end

        def self.find_nslocalizedstrings(file)
          raise "Not implemented"
        end
        


        def self.scan_lines(path)
          File.readlines(file).each_with_index do |line, index|
            yield line, index
          end
        end
      end
    end
  end
end
