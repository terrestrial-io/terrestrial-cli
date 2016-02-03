module Terrestrial
  module Cli
    class FileFinder
      
      EXCLUDED_FOLDERS = [
        /Carthage\//,
        /Pods\//,
        /Tests\//
      ]

      EXCLUDED_FILES = [
        "LaunchScreen.storyboard"
      ]

      def self.find(directory, extensions)
        self.new(directory, extensions).find
      end

      def initialize(directory, extensions)
        @directory  = directory
        @extensions = extensions
      end

      def find
        Dir[@directory + "/**/*.*"]
          .map {|f| relative_path(f) }
          .reject {|f| excluded_folders(f) }
          .select {|f| @extensions.include?(File.extname(f)) }
          .reject {|f| excluded_files(f) }
          .select {|f| valid_paths(f) }
      end

      private

      def relative_path(file)
        Pathname.new(file)
          .relative_path_from(Pathname.new(@directory))
          .to_s
      end

      def valid_paths(f)
        # Some files need to be in specific places to count
        # as "real files". For example, strings.xml files should
        # only be read if they are in /res/values/strings.xml
        #
        # Add rules here as needed.

        case File.extname(f)
        when ".xml"
          f.end_with? "/res/values/strings.xml"
        else
          true
        end
      end
      
      def excluded_folders(path)
        EXCLUDED_FOLDERS.any? { |folder| path.scan(folder).any? }
      end

      def excluded_files(path)
        EXCLUDED_FILES.any? { |name| File.basename(path) == name }
      end
    end
  end
end
