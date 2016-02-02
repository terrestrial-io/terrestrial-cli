module Terrestrial
  module Cli
    class EngineMapper

      PARSERS = {
        ".m" => Terrestrial::Cli::Parser::ObjC,
        ".h" => Terrestrial::Cli::Parser::ObjC,
        ".swift" => Terrestrial::Cli::Parser::Swift,
        ".storyboard" => Terrestrial::Cli::Parser::Storyboard,
        ".xml" => Terrestrial::Cli::Parser::AndroidXML
      }

      EDITORS = {
        ".m" => Terrestrial::Cli::Editor::ObjC,
        ".h" => Terrestrial::Cli::Editor::ObjC,
        ".swift" => Terrestrial::Cli::Editor::Swift,
        ".storyboard" => Terrestrial::Cli::Editor::Storyboard,
        ".xml" => Terrestrial::Cli::Editor::AndroidXML
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
