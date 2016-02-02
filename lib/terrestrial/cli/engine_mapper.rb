module Terrestrial
  module CLI
    class EngineMapper

      PARSERS = {
        ".m" => Terrestrial::CLI::Parser::ObjC,
        ".h" => Terrestrial::CLI::Parser::ObjC,
        ".swift" => Terrestrial::CLI::Parser::Swift,
        ".storyboard" => Terrestrial::CLI::Parser::Storyboard,
        ".xml" => Terrestrial::CLI::Parser::AndroidXML
      }

      EDITORS = {
        ".m" => Terrestrial::CLI::Editor::ObjC,
        ".h" => Terrestrial::CLI::Editor::ObjC,
        ".swift" => Terrestrial::CLI::Editor::Swift,
        ".storyboard" => Terrestrial::CLI::Editor::Storyboard,
        ".xml" => Terrestrial::CLI::Editor::AndroidXML
      }

      def self.parser_for(extension)
        PARSERS[extension]
      end

      def self.editor_for(extension)
        EDITORS[extension]
      end
    end
  end
end
