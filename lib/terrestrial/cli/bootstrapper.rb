module Terrestrial
  module Cli
    class Bootstrapper

      def self.find_new_strings(directory)
        FileFinder.find(directory, EngineMapper::PARSERS.keys)
          .flat_map {|file| Parser.find_strings(file) }
          .select   {|entry| entry.string != "" }
          .each     {|entry| Log.info("Parser found #{entry.inspect}", progname: "Bootstrapper") }
          .select   {|entry| Parser::StringAnalyser.is_string_for_humans?(entry.string, entry.language, entry.variables) }
          .sort_by  {|entry| entry.string }
      end

      def self.find_nslocalizedstrings(directory)
        FileFinder.find(directory,[".m",".mm",".swift"])
          .flat_map {|file| Parser.find_nslocalizedstrings(file) }
          .select   {|entry| entry.string != "" }
          .each     {|entry| Log.info("Parser found #{entry.inspect}", progname: "Bootstrapper") }
          .sort_by  {|entry| entry.string }
      end

      def self.build_approved_entries(entry_hashes)
        entry_hashes.map {|hash| ApprovedStringEntry.new(hash)}
      end

      class NewStringEntry
        attr_accessor :string, :type, :file, :line_number, :variables, :language, :identifier, :metadata

        def initialize(hash = {})
          defaults = {
            variables: []
          }

          defaults.merge(hash).each { |name, value| instance_variable_set("@#{name}", value) }
        end

        def has_variables?
          @variables.any?
        end

        def to_h
          a = instance_variables
            .flat_map {|key| [key.to_s.gsub("@",""), instance_variable_get(key)] }

          # Converts array to a hash where every second item is a key,
          # and every other is value
          Hash[*a] 
        end

        def to_json(options = {})
          to_h.to_json
        end
      end

      class ApprovedStringEntry < NewStringEntry
        attr_accessor :context
      end
    end
  end
end
