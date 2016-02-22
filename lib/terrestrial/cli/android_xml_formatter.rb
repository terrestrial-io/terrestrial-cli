require 'rexml/document'

module Terrestrial
  module Cli
    class AndroidXmlFormatter

      def initialize(entries)
        @entries = entries
      end

      def format_foreign_translation
        root = REXML::Element.new("resources")

        entries.each do |entry|
          root.add_element("string", {
            "name"    => entry.identifier 
          }).add_text(entry.string)
        end

        print_xml(root)
      end

      def print_xml(document)
        # In which we wrestle with REXML's insanity

        REXML::Attribute.class_eval( %q^
                                          def to_string
                                            %Q[#@expanded_name="#{to_s().gsub(/"/, '&quot;')}"]
                                          end
                                      ^)
        formatter = CustomPrinter.new(4) # See editor/printer
        formatter.compact = true
        formatter.write(document,"") + "\n"
      end

      private

      def entries
        @entries
      end
    end
  end
end
