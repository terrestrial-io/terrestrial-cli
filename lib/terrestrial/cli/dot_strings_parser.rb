module Terrestrial
  module Cli
    module DotStringsParser
      class << self

        def parse_file(path)
          entries = do_parse_file read_file_with_correct_encoding(path)
          entries.each do |entry|
            entry["type"] = "localizable.strings"
            entry["file"] = path
          end
        end

        private

        def do_parse_file(contents)
          results = []
          
          multiline_comment = false
          expecting_string  = false
          multiline_string  = false
          current = {}

          contents.split("\n").each do |line|
            line = line.rstrip
            line = remove_comments(line) unless multiline_string

            if !multiline_string && !multiline_comment && line == ""
              # Just empty line between entries
              next 
            elsif line.start_with?("\"") && !line.end_with?(";")
              # Start multiline string"
              current_id = line.split("=").map(&:strip)[0][1..-1][0..-2]
              current_string = line.split("=").map(&:strip)[1][1..-1]

              current["identifier"] = current_id
              current["string"] = current_string unless current_string.empty?
              multiline_string = true
            elsif multiline_string && !line.end_with?(";")
              # Continuing multiline string
              if current["string"].nil?
                current["string"] = line.lstrip
              else
                current["string"] << "\n" + line
              end
            elsif multiline_string && line.end_with?(";")
              # Ending multiline string
              current["string"] << "\n#{line[0..-3]}"
              multiline_string = false
              results << current
              current = {}
            elsif !expecting_string && line.lstrip.start_with?("/*") && !line.end_with?("*/")
              # Start multline comment
              tmp_content = line[2..-1].strip
              current["context"] = "\n" + tmp_content unless tmp_content.empty?
              multiline_comment = true
            elsif multiline_comment && !line.end_with?("*/")
              # Continuing multline comment
              if current["context"].nil?
                current["context"] = line.lstrip
              else
                current["context"] << "\n" + line
              end
            elsif multiline_comment && line.end_with?("*/")
              # Ending multline comment
              tmp_content = line[0..-3].strip
              current["context"] << (tmp_content.empty? ? "" : "\n#{tmp_content}")
              multiline_comment = false
              expecting_string  = true
            elsif !expecting_string && line.start_with?("/*") && line.end_with?("*/")
              # Single line comment
              current["context"] = line[2..-1][0..-3].strip
              expecting_string = true
            elsif expecting_string && line.end_with?(";")
              # Single line id/string pair after a comment
              current_id, current_string = get_string_and_id(line)
              current["identifier"] = current_id
              current["string"] = current_string

              expecting_string = false
              results << current
              current = {}
            elsif !expecting_string && line.end_with?(";")
              # id/string without comment first
              current_id, current_string = get_string_and_id(line)
              current["identifier"] = current_id
              current["string"] = current_string

              results << current
              current = {}
            else
              raise "Don't know what to do with '#{line.inspect}'"
            end
          end
          results
        end

        def get_string_and_id(line)
          id = line.split("=").map(&:strip)[0].gsub("\"", "")
          string = line.split("=").map(&:strip)[1].gsub("\"", "")[0..-2]
          [id, string]
        end

        def read_file_with_correct_encoding(path)
          # Genstrings creates files with BOM UTF-16LE encoding.
          # If we realise that we cannot operate on the content
          # of the file assumin UTF-8, we try UTF-16!

          content = File.read path
          begin 
            # Try performing an operation on the content
            content.split("\n") 
          rescue ArgumentError
            # Failure! We think this is a UTF-16 file 

            # Remove the byte order marker from the beginning
            # of the file. We tried doing this with a simple
            # sub! of \xFF\xFE, but we kept running into 
            # more issues. We instead do it manually.
            content = content.bytes[2..-1].pack('c*')

            # Force UTF-16LE encoding as a setting (not actually
            # changing any representations yet!), then encode from 
            # that to UTF-8 again
            content = content
                        .force_encoding(Encoding::UTF_16LE)
                        .encode!(Encoding::UTF_8)
          end
          content
        end

        def remove_comments(line)
          line = line.split("//")[0] || ""
          line.rstrip
        end
      end
    end
  end
end
