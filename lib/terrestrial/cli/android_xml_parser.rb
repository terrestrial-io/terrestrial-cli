module Terrestrial
  module Cli
    class AndroidXmlParser

      def self.parse_file(file)
        new(file).parse
      end

      def initialize(file)
        @path = file
        @file = File.new(file)
        @document = REXML::Document.new(@file)
      end

      def parse
        result = []
        REXML::XPath.each(@document, "//resources/string[not(@terrestrial='false')]") do |node|
          result << build_entry(node)
        end
        result
      end

      def build_entry(node)
        Hash.new.tap do |entry|
          entry["file"] = @path
          entry["string"] = get_string_from_node(node)
          entry["type"] = "strings.xml"
          entry["identifier"] = node.attributes["name"]
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
    end
  end
end
