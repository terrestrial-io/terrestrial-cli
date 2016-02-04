require 'delegate'

module Terrestrial
  module Cli
    class Bootstrapper

      def self.find_new_strings(directory)
        result  = Result.new
        entries = FileFinder.find(directory, EngineMapper::PARSERS.keys)
          .flat_map {|file| Parser.find_strings(file) }
          .reject   {|entry| entry["string"] == "" }
          .select   {|entry| Parser::StringAnalyser.is_string_for_humans?(
                               entry["string"], entry["language"], entry["variables"])}
        
        entries.each do |entry|
          result.add(entry)
        end
        result
      end
    end

    class Bootstrapper
      class Result
        include Enumerable

        def initialize
          @result_index = 0
        end

        def each(&block)
          entries.each do |entry|
            block.call(entry)
          end
        end

        def each_occurence(&block)
          entries.flat_map(&:as_separate_occurences).each do |entry|
            block.call(entry)
          end
        end

        def all_occurences
          entries.flat_map(&:as_separate_occurences)
        end

        def add(entry_hash)
          match = entries.detect {|e| e.string == entry_hash["string"] }
          if match
            match.add_occurence(entry_hash, next_result_index)
          else
            entries << Entry.from_hash(entry_hash, next_result_index)
          end
        end

        def exclude_occurence(indexes)
          entries.each do |entry|
            entry.occurences.delete_if {|occurence| indexes.include? occurence.result_index }
          end
        end

        def length
          entries.length 
        end

        def [](i)
          entries[i]
        end

        private

        def entries
          @entries ||= []
        end

        def next_result_index
          @result_index += 1 
          @result_index - 1
        end
      end
    end

    class Bootstrapper
      class Entry
        MAX_IDENTIFIER_LENGTH = 10 # words

        def initialize(string, occurences = [])
          @string = string
          @occurences = occurences
        end

        def self.from_hash(hash, index)
          string    = hash.fetch("string")
          occurence = Occurence.from_hash(hash, index)

          new(string, [occurence])
        end

        def identifier
          string
            .split(" ")[0..(MAX_IDENTIFIER_LENGTH - 1)]
            .join("_")
            .upcase
        end

        def string
          @string
        end

        def occurences
          @occurences
        end

        def as_separate_occurences
          occurences.map do |occurence|
            entry_occurence = EntryOccurence.new(occurence)
            entry_occurence.string = self.string
            entry_occurence
          end
        end

        def add_occurence(hash, index)
          if hash.fetch("string") == self.string
            @occurences << Occurence.from_hash(hash, index)
          else
            raise "Add non-matching string '#{hash.fetch("string")}' as an occurence to #{self.inspect}"
          end
        end

        class Occurence < Struct.new(:file, :line_number, :type, :language, :metadata, :result_index)
          def self.from_hash(hash, index)
            new.tap do |occurence|
              occurence.file         = hash.fetch("file")
              occurence.line_number  = hash.fetch("line_number") { nil }
              occurence.type         = hash.fetch("type") { "unknown" }
              occurence.language     = hash.fetch("language")
              occurence.metadata     = hash.fetch("metadata") { Hash.new }
              occurence.result_index = index
            end
          end
        end

        class EntryOccurence < SimpleDelegator
          # Used when separating out occurences for the 
          # editors again
          
          def string=(string)
            @string = string
          end

          def string
            @string
          end

          def formatted_string
            result = string
            if language == :swift
              # Account for Swift's \(interpolated) variables
              result = format_swift_string(result)
            end
            format_string(result)
          end

          def format_swift_string(target_string)
            formatted_string = target_string
            regex = /\\\(.*?\)/
            index = 1
            while formatted_string.scan(regex).any?
              formatted_string = formatted_string.sub(regex, "%#{index}$@")
              index += 1
            end
            formatted_string
          end

          def format_string(target_string)
            formatted_string = target_string
            regex = /\%@/
            index = 1
            while formatted_string.scan(regex).any?
              formatted_string = formatted_string.sub(regex, "%#{index}$@")
              index += 1
            end
            formatted_string
          end
        end
      end
    end
  end
end
