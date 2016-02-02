module Terrestrial
  module Cli
    class DetectsProjectType

      def self.run
        files = Dir[Config[:directory] + "/**/*"]

        if files.any? {|f| f.end_with?(".xcodeproj") || f.end_with?(".xcworkspace")}
          "ios"
        else
          "android"
        end
      end
    end
  end
end
