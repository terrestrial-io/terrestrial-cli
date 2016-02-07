require 'base64'
require 'json'

module Terrestrial
  module Cli
    module MixpanelClient
      class << self

        TOKEN = "47d6a27568a3c842ead24b14907eb04e"
        URL = "https://api.mixpanel.com/track"

        def track(event)
          # If we're live
          if Config[:api_url] == "https://mission.terrestrial.io"
            `curl -silent -X POST #{URL}?data=#{format_event(event)} &`
          end
        end

        def user_identifier
          if Config[:user_id]
            Config[:user_id]
          else
            fetch_and_save_user_id
          end
        end

        def format_event(event)
          Base64.strict_encode64(event_json(event))
        end

        def event_json(event)
          {
            event: event,
            properties: {
              distinct_id: user_identifier,
              token: TOKEN,
              time: Time.now.to_i
            }
          }.to_json
        end

        def fetch_and_save_user_id
          response = Web.new.get_profile
          if response.success?
            id = response.body["data"]["user"]["id"]
            Config.load({:user_id => id})
            Config.update_global_config
            id
          else
            "unknown"
          end
        end
      end
    end
  end
end
