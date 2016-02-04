require 'terrestrial/cli/editor/printer'
require 'terrestrial/cli/editor/base_editor'
require 'terrestrial/cli/editor/objc'
require 'terrestrial/cli/editor/swift'
require 'terrestrial/cli/editor/storyboard'
require 'terrestrial/cli/editor/android_xml'

module Terrestrial
  module Cli
    module Editor
      class << self
        def prepare_files(new_strings)
          @new_strings = new_strings
          run
        end

        private

        def run
          wrap_string_with_sdk_functions
          add_imports
        end

        def add_imports
          @new_strings
            .uniq {|string| string.file}
            .each {|string| editor_for_type(string.file).add_import(string.file)}
        end

        def wrap_string_with_sdk_functions
          @new_strings.each do |string|
            editor_for_type(string.file).find_and_edit_line(string)
          end
        end

        def editor_for_type(file)
          EngineMapper.editor_for(File.extname(file))
        end
      end
    end
  end
end
