module Terrestrial
  module CLI
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
          @path    = entry.file
          @type    = entry.type
          @string  = entry.string
          @id      = entry.metadata["storyboard_element_id"]
          @context = entry.context

          @document = REXML::Document.new(File.new(@path))
        end

        def self.insert_runtime_attribute(entry)
          self.new(entry).insert_attribute
        end

        def insert_attribute
          node = find_node

          # TODO, There was a case when "node" was nil in this point, after
          # trying to find it by type + ID.
          #
          # Keep an eye out for it to see if reproducible

          node.add(create_element(context: @context))
          refresh_document(node)
          save_document
        end

        private

        def find_node
          REXML::XPath.first(@document, query_for(@type, id: @id))
        end

        def refresh_document(node)
          # This is a bit ridiculous, but necessary because
          # &*£(*$)£@*$!£ REXML
          
          @document = REXML::Document.new(node.document.to_s)
        end

        def save_document
          File.open(@path, "w") do |f|
            printer = Printer.new(2)
            printer.width = 1000
            printer.write(@document, f)
          end 
        end

        def query_for(type, id: "")
          # Find element of said type, with the ID, that does not
          # have a userDefinedRuntimeAttribute as a child

          QUERIES[type] + "[@id=\"#{id}\" and not(userDefinedRuntimeAttributes)]]"
        end

        def text_attribute(type)
          Parser::Storyboard::Engine::TEXT_ATTRIBUTE[type]
        end

        def create_element(boolean: true, context: "")
          REXML::Element.new("userDefinedRuntimeAttributes")
                .add_element("userDefinedRuntimeAttribute", 
                     {"type" => "boolean", 
                      "keyPath" => "Terrestrial", 
                      "value" => boolean ? "YES" : "NO" }).parent
                .add_element("userDefinedRuntimeAttribute", 
                     {"type" => "string", 
                      "keyPath" => "contextInfo", 
                      "value" => context || ""}).parent
        end
      end
    end
  end
end
