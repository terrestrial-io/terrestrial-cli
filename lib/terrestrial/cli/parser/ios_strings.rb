module Terrestrial
  module Cli
    module Parser
      class IosStrings
        class << self

          def find_api_calls(file)
            entries = parse_file(File.read file)
            entries.each do |entry|
              entry[:type] = "localizable.strings"
              entry[:file] = file
            end
          end

          private

          def parse_file(contents)
            results = []
            
            expecting_comment = false
            multiline_comment = false
            expecting_string  = false
            multiline_string  = false
            current = {}

            contents.split("\n").each do |line|
              line = line.rstrip

              if !multiline_string && !multiline_comment && !expecting_comment && !expecting_string && line == ""
                # Just empty line between entries
                next 
              elsif !expecting_comment && line.start_with?("\"") && !line.end_with?(";")
                # Start multiline string"
                current_id = line.split("=").map(&:strip)[0][1..-1][0..-2]
                current_string = line.split("=").map(&:strip)[1][1..-1]

                current[:id] = current_id
                current[:string] = current_string unless current_string.empty?
                multiline_string = true
              elsif multiline_string && !line.end_with?(";")
                # Continuing multiline string
                if current[:string].nil?
                  current[:string] = line.lstrip
                else
                  current[:string] << "\n" + line
                end
              elsif multiline_string && line.end_with?(";")
                # Ending multiline string
                current[:string] << "\n#{line[0..-3]}"
                multiline_string = false
                results << current
                current = {}
              elsif !expecting_string && line.lstrip.start_with?("/*") && !line.end_with?("*/")
                # Start multline comment
                tmp_content = line[2..-1].strip
                current[:context] = "\n" + tmp_content unless tmp_content.empty?
                multiline_comment = true
              elsif multiline_comment && !line.end_with?("*/")
                # Continuing multline comment
                if current[:context].nil?
                  current[:context] = line.lstrip
                else
                  current[:context] << "\n" + line
                end
              elsif multiline_comment && line.end_with?("*/")
                # Ending multline comment
                tmp_content = line[0..-3].strip
                current[:context] << (tmp_content.empty? ? "" : "\n#{tmp_content}")
                multiline_comment = false
                expecting_string  = true
              elsif !expecting_string && !expecting_comment && line.start_with?("/*") && line.end_with?("*/")
                # Single line comment
                current[:context] = line[2..-1][0..-3].strip
                expecting_string = true
              elsif expecting_string && line.end_with?(";")
                # Single line id/string pair after a comment
                current_id, current_string = get_string_and_id(line)
                current[:id] = current_id
                current[:string] = current_string

                expecting_string = false
                results << current
                current = {}
              elsif !expecting_string && !expecting_comment && line.end_with?(";")
                # id/string without comment first
                current_id, current_string = get_string_and_id(line)
                current[:id] = current_id
                current[:string] = current_string

                results << current
                current = {}
              else
                raise "Don't know what to do with '#{line.inspect}'"
              end
            end
            results
          end

          def get_string_and_id(line)
            id = line.split("=").map(&:strip)[0][1..-1][0..-2]
            string = line.split("=").map(&:strip)[1][1..-1][0..-3]
            [id, string]
          end
        end
      end
    end
  end
end
