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
            add_file_to_config(lproj_folder)
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
          project_language = detect_project_language(folder_name)
          base_lproj_path = FileUtils.mkdir_p(Config[:directory] + "/#{folder_name}" + "/#{project_language}.lproj").first

          base_lproj_path + "/Localizable.strings"
        end

        def add_file_to_config(path)
          path_to_file = Pathname.new(path)
          current_dir  = Pathname.new(Config[:directory])

          Config.load({ translation_files: [
            path_to_file.relative_path_from(current_dir).to_s
          ]})
          Config.update_project_config
        end

        def detect_project_language(folder)
          info_plist = Dir[Config[:directory] + "/#{folder}/Info.plist"].first
          lang = `defaults read '#{info_plist}' CFBundleDevelopmentRegion 2> /dev/null`.gsub("\n", "").squeeze(" ")

          if lang.empty?
            puts "Unable to detect project language. Defaulting to 'en'."
            'en'
          else
            lang
          end
        end

        def print_done_message(lproj_folder)
          puts "------------------------------------"
          puts "-- Done!"
          puts "- Localizable.strings created in #{lproj_folder}"
          puts "- All strings in source substituted with IDs."
          puts "- Remember to include the new localization files in your project!"
        end

        def print_instructions
          puts "------------------------------------"
          puts "-- Source Code" 
          puts "- Next Terrestrial will modify your source code to reference all the selected strings via IDs."
          puts "-   e.g.  \"This is my string\"  =>  \"This is my string\".translated"
          puts ""
          puts "Continue? y/n?"
        end

        def results
          @results
        end
      end
    end
  end
end
