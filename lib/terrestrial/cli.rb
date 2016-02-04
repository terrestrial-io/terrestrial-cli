require "terrestrial/cli/command"
require "terrestrial/cli/init"
require "terrestrial/cli/flight"
require "terrestrial/cli/version"
require "terrestrial/cli/detects_project_type"
require "terrestrial/cli/file_picker"
require "terrestrial/cli/file_finder"
require "terrestrial/cli/bootstrapper"
require "terrestrial/cli/localizable_strings_writer"
require "terrestrial/cli/parser"
require "terrestrial/cli/editor"
require "terrestrial/cli/engine_mapper"

module Terrestrial
  module Cli

    COMMANDS = ["init", "flight"]

    def self.start(command, opts = {})
      case command
      when "init" 
        init(opts)
      when "flight" 
        flight(opts)
      else
        abort "Unknown command #{command}"
      end
    end

    def self.init(opts)
      Terrestrial::Cli::Init.run(opts)
    end

    def self.flight(opts)
      Terrestrial::Cli::Flight.run(opts)
    end
  end
end
