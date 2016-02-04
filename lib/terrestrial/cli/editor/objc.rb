module Terrestrial
  module Cli
    module Editor
      class ObjC < BaseEditor

        def self.find_and_edit_line(new_string)
          edit_file(new_string.file) do |line, line_number, file|
            if line_number == new_string.line_number
              file.puts do_edit_string(line, new_string)
            else
              file.puts line
            end
          end
        end

        def self.do_edit_string(line, entry)
          string = entry.string
          replacement = add_position_identifiers_to_variables(entry.string)

          line.gsub(a_string_not_followed_by_translated(string), "@\"#{replacement}\".translated")
        end

        def self.add_import(file)
          # Adds #import "Terrestrial.h" as the last import
          # statement at the top of the file.
          #
          # It goes through the file from top to bottom looking for the first import
          # statement. After it finds it, it will look for the first line without
          # an import statement. When it finds it, it will write the import line,
          # and all following lines are just copied over.

          found_first_import = false
          imported = false

          edit_file(file) do |line, line_number, file|
            if !found_first_import && line.start_with?("#import ")
              found_first_import = true
              file.puts line
            elsif line.start_with?("#import <Terrestrial/Terrestrial.h>")
              imported = true
              file.puts line
            elsif !imported && found_first_import && !line.start_with?("#import ")
              file.puts "#import <Terrestrial/Terrestrial.h>"
              file.puts ""
              imported = true
            else
              file.puts line
            end
          end
        end

        def self.a_string_not_followed_by_translated(string)
          # Does not match:
          #
          #   @"foo".translated
          #   or
          #   @"foo" translatedWithContext
          #
          #   (?!(\.|\s)translated) means don't match either
          #   period or single whitepspace character,
          #   followed by translated


          /@"#{string}"(?!(\.|\s)translated)/
        end

        def self.add_position_identifiers_to_variables(string)
          regex = /\%@/
          index = 1
          while string.scan(regex).any?
            string = string.sub(regex, "%#{index}$@")
            index += 1
          end
          string
        end
      end
    end
  end
end
