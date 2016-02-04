require 'rexml/document'

module Terrestrial
  module Cli
    module Parser
      class Storyboard
        LANGUAGE = :ios_storyboard
        attr_reader  :result
        
        include REXML
        QUERIES = {
          "storyboard-label" => "//label",
          "storyboard-text-field" => "//textField",
          "storyboard-button" => "//button/state",
          "storyboard-bar-button-item" => "//barButtonItem",
          "storyboard-navbar-item" => "//navigationItem",
          "storyboard-text-view" => "//textView"
        }

        TEXT_ATTRIBUTE = {
          "storyboard-label" => "text",
          "storyboard-text-field" => "placeholder",
          "storyboard-button" => "title",
          "storyboard-bar-button-item" => "title",
          "storyboard-navbar-item" => "title",
          "storyboard-text-view" => "text"
        }

        TYPES = QUERIES.keys

        def initialize(file)
          @path = file
          @file = File.new(file)
          @document = Document.new(@file)
          @result = []
        end

        def self.find_strings(file)
          self.new(file).find_strings
        end

        def self.find_api_calls(file)
          self.new(file).find_api_calls
        end

        def find_api_calls
          labels = []
          XPath.each(@document, api_calls_query) do |node|
            type    = type_for(node.name)
            string  = get_string(node)
            context = get_context(node)

            labels << build_registry_entry_hash(string, context, type)
          end
          @result = labels
          @result
        end

        def find_strings
          TYPES.each do |type|
            @result.concat(find_entries_for_type(type))
          end
          @result
        end

        

        def type_for(name)
          {
            "label"          => "storyboard-label",
            "textField"      => "storyboard-text-field",
            "button"         => "storyboard-button",
            "barButtonItem"  => "storyboard-bar-button-item",
            "navigationItem" => "storyboard-navbar-item",
            "textView"       => "storyboard-text-view",
          }[name]
        end

        def find_entries_for_type(type)
          labels = []
          XPath.each(@document, QUERIES[type]) do |node|
            labels << new_entry(node.attributes[TEXT_ATTRIBUTE[type]], 
                                    type: type, 
                                      id: get_id(node))
          end
          labels
        end

        def get_id(node)
          # Why? Because the button's text is not in the
          # button, but in a child element, that doesn't have
          # an ID. So for most situations you'll just pick the
          # ID off the element, but sometimes we'll have to 
          # traverse back up to get the ID. If that element
          # doesn't have an ID, it's a new situation and
          # we should get an exception down the line.

          target = node
          if target.attributes["id"].nil?
            target.parent.attributes["id"]
          else
            target.attributes["id"]
          end
        end

        def get_context(node)
          # //textView/userDefinedRuntimeAttributes/userDefinedRuntimeAttribute[@keyPath="contextInfo"]
          context = ""
          attributes = node.elements.select {|e| e.name == "userDefinedRuntimeAttributes"}.first
          attributes.each_element_with_attribute("keyPath", "contextInfo") do |e| 
            context = e.attributes["value"]
          end
          context
        end

        def get_string(node)
          type = type_for(node.name)
          if type == "storyboard-button"
            node.elements.select {|e| e.name == "state"}.first.attributes[TEXT_ATTRIBUTE[type]]
          else
            node.attributes[TEXT_ATTRIBUTE[type]]
          end
        end

        def api_calls_query
          # Finds all the attributes that say that an element is 
          # translated by Terrestrial, and we then traverse
          # two parents up:
          #
          # <*targetElement*>
          #   <userDefinedRuntimeAttributes>
          #     <userDefinedRuntimeAttribute ... />   <- these are what we find

          '//userDefinedRuntimeAttribute[@type="boolean" and @value="YES"]/../..'
        end
        
        def new_entry(string, opts)
          defaults = { type: "storyboard" }
          values = defaults.merge(opts)

          Hash.new.tap do |entry|
            entry["file"] = @path
            entry["language"] = LANGUAGE
            entry["string"] = string.to_s
            entry["type"] = values.fetch(:type)
            entry["line_number"] = nil
            entry["metadata"] = {
              "storyboard_element_id" => values.fetch(:id)
            }
          end
        end

        def build_registry_entry_hash(string, context, type)
          Hash.new.tap do |entry|
            entry["string"] = string.to_s
            entry["language"] = LANGUAGE
            entry["context"] = context || ""
            entry["file"] = @path
            entry["line_number"] = nil
            entry["type"] = type
          end
        end
      end
    end
  end
end
