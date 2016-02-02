require 'terrestrial/web/response'
require 'net/http'
require 'json'

module Terrestrial
  class Web
    
    def initialize(api_token = nil)
      @url   = URI.parse(Config[:api_url])
      @token = api_token || token
    end

    def push(project_id, app_id, strings_and_context)
      post("projects/#{project_id}/apps/#{app_id}/imports", 
      {
        import: {
          entries: strings_and_context
        }
      })
    end

    def create_app(project_id, platform)
      post("projects/#{project_id}/apps", 
      {
        app: {
          platform: platform
        }
      })
    end

    def get_app_strings(project_id, app_id)
      get("projects/#{project_id}/apps/#{app_id}/strings")
    end

    def get_translations(project_id, app_id)
      get("projects/#{project_id}/apps/#{app_id}/translations")
    end

    def get_profile
      get("me")
    end

    private

    def post(path, payload)
      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = true if @url.scheme == "https"

      request = Net::HTTP::Post.new(base_url + path)
      request.body = payload.to_json
      request["Content-Type"] = "application/json"
      request["AUTHENTICATE"] = @token

      Response.new(http.request(request))
    end

    def get(path)
      http = Net::HTTP.new(@url.host, @url.port)
      http.use_ssl = true if @url.scheme == "https"

      request = Net::HTTP::Get.new(base_url + path)
      request["Content-Type"] = "application/json"
      request["AUTHENTICATE"] = @token

      Response.new(http.request(request))
    end

    def base_url
      @url.request_uri
    end

    private

    def token
      Config[:api_key]
    end
  end
end
