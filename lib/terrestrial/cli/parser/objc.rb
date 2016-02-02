module Terrestrial
  module Cli
    module Parser
      class ObjC < BaseParser
        LANGUAGE = :objc

        STRING_REGEX = /@"(.*?)"/
        NSLOCALIZEDSTRING_REGEX = /NSLocalizedString\(.*@"(.*)".*\)/
        DOT_TRANSLATED_REGEX = /@"([^"]*)".translated\W/
        TRANSLATED_WITH_CONTEXT_REGEX = /@"([^"]*)"\stranslatedWithContext:/

        def self.find_strings(file)
          results = []
          if is_view_controller?(file)
            File.readlines(file, :encoding => "UTF-8").each_with_index do |line, index|
              line.encode!('UTF-16', :undef => :replace, :invalid => :replace, :replace => "")
              line.encode!('UTF-8')
              results.concat(analyse_line_for_strings(line,index, file))
            end
          end
          results
        end

        

        def self.analyse_line_for_strings(line, index, file_path)
          results = []
          line.scan(STRING_REGEX).each do |match|
            unless looks_suspicious(line)
              results.push(Bootstrapper::NewStringEntry.new.tap do |entry|
                entry.language = LANGUAGE
                entry.file = file_path
                entry.line_number = index + 1
                entry.string = match[0]
                entry.type = guess_type(line)
               # entry.variables = get_variable_names(line) if entry.type == "stringWithFormat"

              end)
            end
          end
          results
        end

        def self.find_nslocalizedstrings(file)
          results = []
          #if is_view_controller?(file)
            File.readlines(file).each_with_index do |line, index|
              
              joining_array = analyse_line_for_nslocalizedstrings(line,index, file)
              if !joining_array.empty? 
              results.concat(joining_array)
              break
              end

            end
          #end
          results
        end

        def self.analyse_line_for_nslocalizedstrings(line, index, file_path)
          results = []
          line.scan(NSLOCALIZEDSTRING_REGEX).each do |match|
           
              results.push(Bootstrapper::NewStringEntry.new.tap do |entry|
                entry.language = LANGUAGE
                entry.file = file_path
                entry.line_number = index + 1
                entry.string = match[0]
                entry.type = guess_type(line)
               # entry.variables = get_variable_names(line) if entry.type == "stringWithFormat"

              end)
            
          end
          results
        end

        

        def self.find_api_calls(file)
          results = []
          File.readlines(file).each_with_index do |line, index|
            results.concat(analyse_line_for_dot_translated(line, index, file))
            results.concat(analyse_line_for_translatedWithContext(line, index, file))
          end
          results
        end

        def self.analyse_line_for_translatedWithContext(line, index, file_path)
          results = []
          line.scan(TRANSLATED_WITH_CONTEXT_REGEX).each do |match|
            results.push(Hash.new.tap do |h|
              h["file"] = file_path
              h["line_number"] = index + 1
              h["string"] = match[0]
              h["type"] = "translatedWithContext"
              h["context"] = get_context(line, h["string"])
            end)
          end
          results
        end

        def self.analyse_line_for_dot_translated(line, index, file_path)
          results = []
          line.scan(DOT_TRANSLATED_REGEX).each do |match|
            results.push(Hash.new.tap do |h|
              h["file"] = file_path
              h["line_number"] = index + 1
              h["string"] = match[0]
              h["type"] = ".translated"
              h["context"] = ""
            end)
          end
          results
        end

        def self.get_context(line, match)
          line.match(/"#{match}" translatedWithContext:\s?@"([^"]*)"/)[1]
        end

        def self.guess_type(line)
          if line.include? "stringWithFormat"
            "stringWithFormat"
          else
            "unknown"
          end
        end

        def self.get_variable_names(line)
          line
            .scan(/stringWithFormat:\s?@"[^"]+",\s?(.*?)\][^\s*,]/)
            .first.first # Array of arrays Yo.
            .split(",")
            .map {|var| var.gsub(/\s+/, "")}
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
          without_strings.downcase.include?("static ") ||
          without_strings.downcase.include?("print(")
        end

        def self.is_view_controller?(file)
          !file.match(/ViewController/).nil?
        end
      end
    end
  end
end
