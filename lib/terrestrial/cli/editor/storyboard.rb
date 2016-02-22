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
          @type          = entry.type
          @string        = entry.string
          @storyboard_id = entry.metadata["storyboard_element_id"]
          @identifier    = entry.identifier

          @document = REXML::Document.new(File.new(@path))
        end

        def self.insert_runtime_attribute(entry)
          self.new(entry).insert_attribute
        end

        def insert_attribute
          puts "DEBUG: Finding node #{@storyboard_id} in file #{@path}"
          node = find_node

          if node.nil?
            puts "DEBUG: Was not able to find node!"
            abort "Node was not found."
          end

          # TODO, There was a case when "node" was nil in this point, after
          # trying to find it by type + ID.
          #
          # Keep an eye out for it to see if reproducible

          node.add(create_element)
          refresh_document(node)
          save_document
        end

        private

        def find_node
          REXML::XPath.first(@document, query_for(@type, storyboard_id: @storyboard_id))
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

        def query_for(type, storyboard_id: "")
          # Find element of said type, with the ID, that does not
          # have a userDefinedRuntimeAttribute as a child

          QUERIES[type] + "[@id=\"#{storyboard_id}\" and not(userDefinedRuntimeAttributes)]]"
        end

        def text_attribute(type)
          Parser::Storyboard::Engine::TEXT_ATTRIBUTE[type]
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
