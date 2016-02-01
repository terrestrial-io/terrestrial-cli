require "terrestrial/cli/command"
require "terrestrial/cli/init"
require "terrestrial/cli/version"

module Terrestrial
  module Cli

    COMMANDS = ["init"]

    def self.start(command, opts = {})
      case command
      when "init" 
        init(opts)
      end
    end

    def self.init(opts)
      Terrestrial::Cli::Init.run(opts)
    end
  end
end
