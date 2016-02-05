module Terrestrial
  module Cli
    class EntryCollectionDiffer

      def self.omissions(first, second)
        first.select do |a|
          !second.any? {|b| match?(a, b)}
        end
      end

      def self.additions(first, second)
        second.reject do |b| 
          first.any? {|a| match?(a, b) }
        end
      end
      
      def self.match?(a, b)
        a.fetch("identifier") == b.fetch("identifier")
      end
    end
  end
end
