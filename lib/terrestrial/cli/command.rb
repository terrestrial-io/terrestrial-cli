module Terrestrial
  module Cli
    class Command

      def initialize(opts)
        @opts = opts
      end

      def self.run(opts = {})
        self.new(opts).run
      end

      private

      def opts
        @opts
      end
    end
  end
end
