module Terrestrial
  module Cli
    module Parser
      class StringAnalyser

        def self.is_string_for_humans?(string, language, variables = [])
          self.new(string, language, variables).decide
        end

        def initialize(string, language, variables = [])
          @string    = string
          @variables = variables || [] # TODO: Find out what was passing in variables as nil instead of empty array
          @language  = language
        end
        
        def decide
          if @variables.any?
            looks_like_string_without_variables?
          else
            if has_camel_case_words? || looks_like_sql? || is_number? || has_snake_case_words?
              false
            elsif number_of_words > 1 && percentage_of_none_alphanumeric < 0.15
              true
            elsif number_of_words == 1 && is_capitalised? && percentage_of_none_alphanumeric < 0.1
              true
            else
              false
            end
          end
        end

        def is_number?
          !(@string =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil?
        end

        def number_of_words
          @string.split(" ").length
        end

        def percentage_of_none_alphanumeric
          total = @string.split("").length.to_f
          non_alphanumeric = @string
                              .split("")
                              .select {|c| /[0-9a-zA-Z i\s]/.match(c).nil? }
                              .length
                              .to_f

          non_alphanumeric / total
        end

        def looks_like_sql?
          # Handle SQL with clever regex
          !@string.match(/(ALTER|CREATE|DROP) TABLE/).nil? ||
          !@string.match(/(DELETE|SELECT|INSERT|UPDATE).+(FROM|INTO|SET)/).nil? ||
          !@string.match(/(delete|select|insert|update).+(from|into|set)/).nil?
        end

        def has_weird_characters?
          (@string.split("") & ["<",">","\\", "/","*"]).length > 0
        end

        def has_punctuation?
          (@string.split("") & [".",",","=","&"]).length > 0
        end

        def has_camel_case_words?
          @string.split(" ")
            .select {|word| !word.match(/([a-zA-Z][a-z]+[A-Z][a-zA-Z]+)/).nil? }
            .any?
        end

        def has_camel_case_words?
          @string.split(" ")
            .select {|word| !word.match(/([a-zA-Z][a-z]+[A-Z][a-zA-Z]+)/).nil? }
            .any?
        end

        def has_snake_case_words?
          @string.split(" ")
            .select {|word| !word.match(/\b\w*(_\w*)+\b/).nil? }
            .any?
        end

        def is_capitalised?
          @string == @string.capitalize
        end

        def looks_like_string_without_variables?
          # Strip away the variables, remove extra whitespace,
          # and feed that string back into the system to see
          # if it now looks human readable or not.

          if @language == ObjC::LANGUAGE
            new_string = @string
                           .gsub(/(%@)|(%d)/, "")
                           .gsub(/\s\s/, " ")
          elsif @language == Swift::LANGUAGE
            new_string = @string
                           .gsub(/\\\(.*\)/, "")
                           .gsub(/\s\s/, " ")
          elsif @language == AndroidXML::LANGUAGE
            new_string = @string

            @variables.each do |v|
              new_string = new_string.gsub(v, "")
              new_string = new_string.gsub(/\s\s/, " ")
            end
          end

          self.class.new(new_string, @language).decide
        end
      end
    end
  end
end
