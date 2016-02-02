module Terrestrial
  module CLI
    module Editor
      class Swift < BaseEditor

        def self.find_and_edit_line(new_string)
          edit_file(new_string.file) do |line, line_number, file|
            if line_number == new_string.line_number
              file.puts do_edit_string(line, new_string)
            else
              file.puts line
            end
            line_number += 1
          end
        end

        def self.do_edit_string(line, entry)
          if entry.variables.any?
            edit_with_variables(line, entry)
          else
            if entry.context
              line.gsub(a_string_not_followed_by_translated(entry.string), "\"#{entry.string}\".translatedWithContext(\"#{entry.context}\")")
            else
              line.gsub(a_string_not_followed_by_translated(entry.string), "\"#{entry.string}\".translated")
            end
          end
        end

        def self.edit_with_variables(line, entry)
          line.gsub(a_string_not_followed_by_translated(entry.string), build_string_with_variables(entry))
        end

        def self.build_string_with_variables(entry)
          if entry.context
            "NSString(format: \"#{make_variables_positional(entry.string)}\".translatedWithContext(\"#{entry.context}\"), #{entry.variables.join(", ")})"
          else
            "NSString(format: \"#{make_variables_positional(entry.string)}\".translated, #{entry.variables.join(", ")})"
          end
        end

        def self.make_variables_positional(string)
          regex = /\\\(.*?\)/
          index = 1
          while string.scan(regex).any?
            string = string.sub(regex, "%#{index}$@")
            index += 1
          end
          string
        end

        def self.add_import(file)
          # Adds import Terrestrial as the last import
          # statement at the top of the file.
          #
          # It goes through the file from top to bottom looking for the first import
          # statement. After it finds it, it will look for the first line without
          # an import statement. When it finds it, it will write the import line,
          # and all following lines are just copied over.

          found_first_import = false
          imported = false

          edit_file(file) do |line, line_number, file|
            # Detect first import statement
            if !found_first_import && line.start_with?("import ")
              found_first_import = true
              file.puts line
            # Terrestrial had already been imported
            elsif line.start_with?("import Terrestrial")
              imported = true
              file.puts line
            # Not imported, had found first import, and doesn't start with "import"
            #   -> import
            elsif !imported && found_first_import && !line.start_with?("import ")
              file.puts "import Terrestrial"
              file.puts ""
              imported = true
            # Copy over as normal
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


          /"#{Regexp.quote(string)}"(?!\.translated)/
        end
      end
    end
  end
end
