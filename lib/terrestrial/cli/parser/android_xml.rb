module Terrestrial
  module Cli
    module Parser
      class AndroidXML < BaseParser
        LANGUAGE = :android_xml

        def self.find_strings(file)
          self.new(file).find_strings
        end

        def self.find_api_calls(file)
          self.new(file).find_api_calls
        end

        def initialize(file)
          @path = file
          @file = File.new(file)
          @document = REXML::Document.new(@file)
        end

        def find_strings
          result = []
          REXML::XPath.each(@document, "//resources/string") do |node|
            result << build_new_string_entry(node)
          end
          result
        end

        def find_api_calls
          result = []
          REXML::XPath.each(@document, "//resources/string[@terrestrial=\"true\"]") do |node|
            result << build_registry_entry_hash(node)
          end
          result
        end

        def build_new_string_entry(node)
          Bootstrapper::NewStringEntry.new.tap do |entry|
            entry.language = LANGUAGE
            entry.file = @path
            entry.string = get_string_from_node(node)
            entry.type = "android-strings-xml"
            entry.line_number = nil
            # entry.variables = get_variables_from_string(entry.string)
            entry.identifier = node.attributes["name"]
          end
        end

        def build_registry_entry_hash(node)
          Hash.new.tap do |entry|
            entry["string"] = get_string_from_node(node)
            entry["context"] = node.attributes["context"] || ""
            entry["file"] = @path
            entry["line_number"] = nil
            entry["type"] = "android-strings-xml"
            entry["id"] = node.attributes["name"]
          end
        end

        def get_string_from_node(node)
          # Why could the text be nil?
          #  - If it contains valid XML!
          #
          # We assume anything inside the string tag is actually 
          # what should be shown in the UI, so we just parse it 
          # as a string if we realise that the parser thinks it
          # is XML.

          if !node.get_text.nil?
            node.get_text.value
          else
            node.children.first.to_s
          end
        end

        def get_variables_from_string(string)
          string.scan(/(\%\d\$[dsf])/).map {|match| match[0] }
        end
      end
    end
  end
end
