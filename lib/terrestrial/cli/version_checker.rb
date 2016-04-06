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

        if higher_version?(version, Terrestrial::Cli::VERSION)
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

      def self.higher_version?(v1, v2)
        # Is v1 a higher semantic versioning number than v2?
        v1 = v1.split('.').reject {|i| i.to_i.to_s != i }.map(&:to_i)
        v2 = v2.split('.').reject {|i| i.to_i.to_s != i }.map(&:to_i)

        v1.each_with_index do |e, i|
          if e > v2[i] 
            return true
          end
        end
        false
      end
    end
  end
end

