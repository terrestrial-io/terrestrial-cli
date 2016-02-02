require 'pathname'

module Terrestrial
  module Cli
    class FilePicker
      class << self

        def run(files)
          puts "Terrestrial detected the following .strings files. Select the ones you want Terrestrial to track."
          puts "(You can configure this later via the terrestrial.yml configuration file in your project directory.)"
          puts "" 

          files.each_with_index do |path, i|
            puts "  (#{i + 1}) #{path}"
          end
          puts ""
          puts "Type the indexes of the files you wish to track, separated by commas."
          puts "  e.g.: \"1,4,5\""
          puts "To not select any files, just hit return"

          result = STDIN.gets.chomp

          process_result(result, files)
        end

        def process_result(result, files)
          if result == ""
            return []
          else
            result
              .split(",")
              .map {|i| i.to_i}
              .map {|i| files[i - 1]}
          end
        end
      end
    end
  end
end
