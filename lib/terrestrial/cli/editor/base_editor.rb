module Terrestrial
  module CLI
    module Editor
      class BaseEditor

        def self.find_and_edit_line(string_entry)
          raise "Not implemented"
        end

        def self.add_import(file)
          raise "Not implemented"
        end

        def self.edit_file(path)
          temp_file = Tempfile.new(File.basename(path))
          begin
            line_number = 1
            File.open(path, 'r') do |file|
              file.each_line do |line|
                yield line, line_number, temp_file
                line_number += 1
              end
            end
            temp_file.close
            FileUtils.mv(temp_file.path, path)
          ensure
            temp_file.close
            temp_file.unlink
          end
        end
      end
    end
  end
end
