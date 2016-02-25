module Terrestrial
  module Cli
    module Editor
      class Storyboard < BaseEditor

        QUERIES = {
          "storyboard-label" => "//label",
          "storyboard-text-field" => "//textField",
          "storyboard-button" => "//button",
          "storyboard-bar-button-item" => "//barButtonItem",
          "storyboard-navbar-item" => "//navigationItem",
          "storyboard-text-view" => "//textView"
        }

        def self.find_and_edit_line(approved_string)
          insert_runtime_attribute(approved_string)
        end


        def self.add_import(file)
          # Not needed
          # Override parent class implementation
        end

        def initialize(entry)
          @path          = entry.file
          @document      = REXML::Document.new(File.new(@path))

          @type          = entry.type
          @string        = entry.string
          @storyboard_id = entry.metadata["storyboard_element_id"]
          @identifier    = entry.identifier

          set_document_to_double_quotes
        end

        def self.insert_runtime_attribute(entry)
          editor = self.new(entry)
          editor.insert_attribute
          editor.save_document
        end

        def insert_attribute
          node = find_node(@storyboard_id, @type)

          # TODO, There was a case when "node" was nil in this point, after
          # trying to find it by type + ID.
          #
          # Keep an eye out for it to see if reproducible

          if node.nil?
            puts "Warning: Was not able to find #{@type} with string '#{@string}' and ID '#{@storyboard_id}' in #{@path}."
            puts "It will not be added to your Localizable.strings file automatically."
          else
            node.add(create_element)
          end
          refresh_document(node)
        end

        def find_node(id, type)
          REXML::XPath.first(@document, query_for(type, storyboard_id: id))
        end

        def save_document
          File.open(@path, "w") do |f|
            f.write "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n"
            f.write format_document
          end 
        end

        def format_document
          printer = CustomPrinter.new(4)
          printer.width = 1000
          printer.compact = true
          printer.write(@document.root, "")
        end

        private

        def refresh_document(node)
          # This is a bit ridiculous, but necessary because
          # &*£(*$)£@*$!£ REXML
          
          @document = REXML::Document.new(node.document.to_s)
          set_document_to_double_quotes
        end

        def query_for(type, storyboard_id: "")
          # Find element of said type, with the ID, that does not
          # have a userDefinedRuntimeAttribute as a child

          QUERIES[type] + "[@id=\"#{storyboard_id}\" and not(userDefinedRuntimeAttributes[@Terrestrial])]"
        end

        def text_attribute(type)
          Parser::Storyboard::Engine::TEXT_ATTRIBUTE[type]
        end

        def set_document_to_double_quotes
          @document.context[:attribute_quote] = :quote
        end

        def create_element
          REXML::Element.new("userDefinedRuntimeAttributes")
                .add_element("userDefinedRuntimeAttribute", 
                     {"type" => "boolean", 
                      "keyPath" => "Terrestrial", 
                      "value" => "YES" }).parent
                .add_element("userDefinedRuntimeAttribute", 
                     {"type" => "string", 
                      "keyPath" => "Identifier", 
                      "value" => @identifier }).parent
        end
      end
    end
  end
end
