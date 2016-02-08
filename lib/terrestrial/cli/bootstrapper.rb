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

        def exclude_occurences(indexes)
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

        def entries
          @entries ||= []
        end

        private

        def next_result_index
          @result_index += 1 
          @result_index - 1
        end
      end
    end

    class Bootstrapper
      class Entry

        def initialize(string, occurences = [])
          @string = string
          @occurences = occurences
        end

        def formatted_string
          if occurences.any? {|occ| occ.language == :swift}
            VariableNormalizer.run(string, swift: true)
          else
            VariableNormalizer.run(string)
          end
        end

        def self.from_hash(hash, index)
          string    = hash.fetch("string")
          occurence = Occurence.from_hash(hash, index)

          new(string, [occurence])
        end

        def identifier
          IdGenerator.generate(formatted_string)
        end

        def string
          @string
        end

        def occurences
          @occurences
        end

        def as_separate_occurences
          occurences.map do |occurence|
            EntryOccurence.new(occurence).tap do |occ|
              occ.string     = self.string
              occ.identifier = self.identifier
            end
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

          def identifier=(identifier)
            @identifier = identifier
          end

          def identifier
            @identifier
          end

          def formatted_string
            if language == :swift
              VariableNormalizer.run(string, swift: true)
            else
              VariableNormalizer.run(string)
            end
          end
        end
      end

      class IdGenerator
        MAX_IDENTIFIER_LENGTH = 10 # words

        class << self
          def generate(string)
            id = do_generate_id(string)

            attempt = 1
            while id_already_exists?(id)
              id = increment_id(id, attempt)
              attempt += 1
            end
            id_history << id
            id
          end

          def reset!
            @history = []
          end

          private

          def increment_id(id, attempt)
            if id[-1] == (attempt - 1).to_s
              id[-1] = attempt.to_s
              id
            else
              id << "_#{attempt}"
            end
          end

          def do_generate_id(string)
            string
              .gsub(/%\d\$@/, '')
              .gsub(/[^0-9a-z ]/i, '')
              .split(" ")[0..(MAX_IDENTIFIER_LENGTH - 1)]
              .join("_")
              .upcase
          end

          def id_already_exists?(id)
            id_history.any? {|previous| previous == id }
          end

          def id_history
            @history ||= []
          end
        end
      end
    end
  end
end
