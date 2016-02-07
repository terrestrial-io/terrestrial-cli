require 'pathname'

module Terrestrial
  module Cli
    class FilePicker
      class << self

        def run(files, platform)
          if files.count == 1
            single_file_workflow(files)
          else
            multiple_files_workflow(files)
          end
        end

        def multiple_files_workflow(files)
          puts "-- Terrestrial detected #{files.count} localization files:"
          files.each_with_index do |path, i|
            puts "(#{i + 1}) #{path}"
          end
          puts ""
          puts "Select the files you want Terrestrial to track as the base localization: e.g. \"1,4,5\""
          puts "(To not select any files, just hit return. You can edit tracked files in terrestrial.yml)"

          result = STDIN.gets.chomp

          process_result(result, files)
        end

        def single_file_workflow(files)
          puts "Terrestrial detected #{files.count} file:"
          puts "(1) #{files[0].to_s}"
          puts ""
          puts "Use this file as your base language file? (you can change this late in terrestrial.yml) y/n?"

          result = STDIN.gets.chomp.strip

          if result == "y"
            files
          else
            []
          end
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
