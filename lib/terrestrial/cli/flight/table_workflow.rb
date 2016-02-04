module Terrestrial
  module Cli
    class Flight < Command
      class TableWorkflow

        LOCAL_CONFIG = {
          strings_per_page: 10
        }

        def initialize(bootstrap_results)
          @results = bootstrap_results
        end

        def run
          print_instructions

          exclusions = []
          i = 0

          results.all_occurences.each_slice(LOCAL_CONFIG[:strings_per_page]).with_index do |five_strings, index|
            puts "Page #{index + 1} of #{(results.all_occurences.count / LOCAL_CONFIG[:strings_per_page].to_f).ceil}"

            table = create_string_table(five_strings, i)
            i += LOCAL_CONFIG[:strings_per_page]
            puts table
            print_instructions
            puts ""

            command = STDIN.gets.chomp
            if command == 'q'
              abort "Aborting..."
            else
              begin
                exclusions.concat(command.split(",").map(&:to_i))
              rescue
                abort "Couldn't process that command :( Aborting..."
              end
            end
          end
          exclusions
        end

        private

        def create_string_table(strings, i)
          Terminal::Table.new(headings: ['Index', 'String', 'File']) do |t|
            strings.each_with_index do |string, tmp_index|
              t.add_row([i, string.string, file_name_with_line_number(string)])
              t.add_separator unless tmp_index == (strings.length - 1) || i == (strings.length - 1)
              i += 1
            end
          end
        end

        def print_instructions
          puts "-- Instructions --"
          puts "- To exclude any strings from translation, type the index of each string."
          puts "-   e.g. 1,2,4"
          puts "------------------"
          puts "Any Exclusions? (press return to continue or 'q' to quit at any time)"
        end

        def file_name_with_line_number(string)
          if string.line_number
            "#{string.file}:#{string.line_number}"
          else
            string.file
          end
        end

        def results
          @results
        end
      end
    end
  end
end
