module Terrestrial
  module Cli
    class Flight < Command
      class IosWorkflow
        
        def initialize(bootstrap_results)
          @results = bootstrap_results
        end

        def run
          print_instructions
          command = STDIN.gets.chomp

          if command == "y"
            lproj_folder = TerminalUI.show_spinner do
              Editor.prepare_files(results.all_occurences)
              initalize_localizable_strings_files
            end
            print_done_message(lproj_folder)
          end
        end

        private

        def initalize_localizable_strings_files
          path = create_path_to_localization_files

          File.open(path, "a+") do |f|
            formatter = DotStringsFormatter.new(results)

            f.write "// Created by Terrestrial (#{Time.now.to_s})"
            f.write "\n\n"
            f.write formatter.format
          end
          path
        end

        def create_path_to_localization_files
          folder_name = Pathname.new(Dir[Config[:directory] + "/*.xcodeproj"].first).basename(".*").to_s
          base_lproj_path = FileUtils.mkdir_p(Config[:directory] + "/#{folder_name}" + "/Base.lproj").first

          base_lproj_path + "/Localizable.strings"
        end

        def print_done_message(lproj_folder)
          puts "------------------------------------"
          puts "-- Done!"
          puts "- Created Base.lproj in #{lproj_folder}."
          puts "- Remember to include the new localization files in your project!"
        end

        def print_instructions
          puts "- Terrestrial will add #{results.length} strings to your base Localizable.strings."
          puts ""
          puts "------------------------------------"
          puts "-- Source Code" 
          puts "- Would you like Terrestrial to also modify the selected strings in your"
          puts "- source code to call .translated?"
          puts "-   e.g.  \"This is my string\"  =>  \"This is my string\".translated"
          puts ""
          puts "y/n?"
        end

        def results
          @results
        end
      end
    end
  end
end
