require 'json'

module Terrestrial
  module Cli
    class VersionChecker
    
      URL = 'https://api.github.com/repos/terrestrial-io/terrestrial-cli/releases/latest'

      def self.run
        response = Net::HTTP.get_response(URI(URL))
        json = JSON.load(response.body)

        # Ignore the "v" in "v1.1.1"
        begin 
          version = json["tag_name"][1..-1]
        rescue NoMethodError => e
          # Github ratelimiting will change the JSON response.
          # Keep calm and carry on.

          version = Terrestrial::Cli::VERSION
        end

        if version != Terrestrial::Cli::VERSION
          puts "There is an update for Terrestrial: #{version} (your version: #{Terrestrial::Cli::VERSION})"
          puts "Run 'gem update terrestrial-cli' to update."
          puts ""
        end
      rescue JSON::ParserError => e
        # Don't worry about JSON parsing errors - just carry on
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
        # Don't worry about Net HTTP errors - just carry on
      end
    end
  end
end

