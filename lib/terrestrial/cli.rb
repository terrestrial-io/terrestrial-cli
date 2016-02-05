require "terrestrial/cli/command"
require "terrestrial/cli/init"
require "terrestrial/cli/flight"
require "terrestrial/cli/ignite"
require "terrestrial/cli/version"
require "terrestrial/cli/variable_normalizer"
require "terrestrial/cli/terminal_ui"
require "terrestrial/cli/detects_project_type"
require "terrestrial/cli/file_picker"
require "terrestrial/cli/file_finder"
require "terrestrial/cli/bootstrapper"
require "terrestrial/cli/dot_strings_formatter"
require "terrestrial/cli/parser"
require "terrestrial/cli/editor"
require "terrestrial/cli/engine_mapper"

module Terrestrial
  module Cli

    COMMANDS = ["init", "flight", "ignite"]

    def self.start(command, opts = {}, args = [])
      case command
      when "init" 
        init(opts)
      when "flight" 
        flight(opts)
      when "ignite" 
        ignite(opts, args)
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

    def self.ignite(opts, args)
      opts["language"] = args[0]
      Terrestrial::Cli::Ignite.run(opts)
    end
  end
end
