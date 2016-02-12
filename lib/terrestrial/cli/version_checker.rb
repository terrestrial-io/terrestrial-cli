require 'json'

module Terrestrial
  module Cli
    class VersionChecker
    
      URL = 'https://api.github.com/repos/terrestrial-io/terrestrial-cli/releases/latest'

      def self.run
        response = Net::HTTP.get_response(URI(URL))
        json = JSON.load(response.body)

        # Ignore the "v" in "v1.1.1"
        version = json["tag_name"][1..-1]

        if version != Terrestrial::Cli::VERSION
          puts "There is an update for Terrestrial: #{version} (your version: #{Terrestrial::Cli::VERSION})"
          puts "Run 'gem update terrestrial-cli' to update."
          puts ""
        end
      end
    end
  end
end

