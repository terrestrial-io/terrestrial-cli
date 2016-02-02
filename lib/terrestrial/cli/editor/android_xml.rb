module Terrestrial
  module CLI
    module Editor
      class AndroidXML < BaseEditor

        def self.find_and_edit_line(string_entry)
          self.new(string_entry).add_attributes
        end

        def self.add_import(file)
          # Not needed
        end

        def initialize(entry)
          @path = entry.file
          @type = entry.type
          @string = entry.string
          @context = entry.context
          @identifier = entry.identifier

          @document = REXML::Document.new(File.new(@path))
          @document.context[:attribute_quote] = :quote 
        end

        def add_attributes
          node = find_node(@identifier)
          node.add_attribute("context", @context) unless @context.nil? || @context.empty?
          node.add_attribute("terrestrial", true) 
          refresh_document(node)
          save_document
        end

        def find_node(name)
          REXML::XPath.first(@document, "//resources/string[@name=\"#{name}\"]")
        end

        def refresh_document(node)
          # This is a bit ridiculous, but necessary because
          # &*£(*$)£@*$!£ REXML
          
          @document = REXML::Document.new(node.document.to_s)
        end

        def save_document
          # AAAAAAAARARARARARARRARAAAGH REXML STAAAAHP
          # You can't make REXML print attributes inside double
          # quotes without monkey patching >.<
          #
          # ...seriously?

          REXML::Attribute.class_eval( %q^
                                            def to_string
                                              %Q[#@expanded_name="#{to_s().gsub(/"/, '&quot;')}"]
                                            end
                                        ^)
          File.open(@path, "w") do |f|
            printer = Printer.new(2)
            printer.compact = true
            printer.width = 1000000
            printer.write(@document, f)
          end 
        end
      end
    end
  end
end
