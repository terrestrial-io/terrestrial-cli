module Terrestrial
  module Cli
    module Parser
      class Swift
        LANGUAGE = :swift

        NSLOCALIZEDSTRING_REGEX = /NSLocalizedString\(.*"(.*)".*\)/
        STRING_REGEX = /"([^"]*)"/
        DOT_TRANSLATED_REGEX = /"([^"]*)".translated\W/
        TRANSLATED_WITH_CONTEXT_REGEX = /"([^"]*)".translatedWithContext/
        VARIABLE_REGEX = /\\\((.*?)\)/

        def self.find_strings(file)
          results = []
          if is_view_controller?(file)
            File.readlines(file).each_with_index do |line, index|
              results.concat analyse_line_for_strings(line, index, file)
            end
          end
          results
        end

        def self.analyse_line_for_strings(line, index, file_path)
          results = []
          line.scan(STRING_REGEX).each do |match|
            unless looks_suspicious(line)
              results.push(Hash.new.tap do |entry|
                entry["language"] = LANGUAGE
                entry["file"] = file_path
                entry["line_number"] = index + 1
                entry["string"] = match[0]
                entry["type"] = find_variables(match[0]).any? ? "stringWithFormat" : "unknown"
                # entry.variables = find_variables(match[0])
              end)
            end
          end
          results
        end

        def self.find_api_calls(file)
          results = []
          File.readlines(file).each_with_index do |line, index|
            line.scan(DOT_TRANSLATED_REGEX).each do |match|
              results.push(Hash.new.tap do |h|
                h["file"] = file
                h["line_number"] = index + 1
                h["string"] = match[0]
                h["type"] = ".translated"
                h["context"] = ""
              end)
            end

            line.scan(TRANSLATED_WITH_CONTEXT_REGEX).each do |match|
              results.push(Hash.new.tap do |h|
                h["file"] = file
                h["line_number"] = index + 1
                h["string"] = match[0]
                h["type"] = "translatedWithContext"
                h["context"] = get_context(line, h["string"])
              end)
            end
          end
          results
        end

        def self.get_context(line, match)
          line.match(/"#{match}"\.translatedWithContext\("([^"]*)"\)/)[1]
        end

        def self.find_variables(string)
          # tries to find \(asd) inside the string itself
          string.scan(VARIABLE_REGEX).map {|matches| matches[0]}
        end

        def self.is_view_controller?(file)
          !file.match(/ViewController/).nil?
        end

        def self.looks_suspicious(line)
          without_strings = line.gsub(STRING_REGEX, "")
          without_strings.include?("_LOG") || 
          without_strings.include?("DLog") || 
          without_strings.include?("NSLog") || 
          without_strings.include?("NSAssert") ||
          without_strings.downcase.include?("uistoryboard") ||
          without_strings.downcase.include?("instantiateviewcontrollerwithidentifier") ||
          without_strings.downcase.include?("uiimage") ||
          without_strings.downcase.include?("nsentitydescription") ||
          without_strings.downcase.include?("nspredicate") ||
          without_strings.downcase.include?("dateformat") ||
          without_strings.downcase.include?("datefromstring") ||
          without_strings.downcase.include?("==") ||
          without_strings.downcase.include?("isequaltostring") ||
          without_strings.downcase.include?("valueforkey") ||
          without_strings.downcase.include?("cellidentifier") ||
          without_strings.downcase.include?("uifont") ||
          without_strings.downcase.include?("print(")
        end
      end
    end
  end
end
