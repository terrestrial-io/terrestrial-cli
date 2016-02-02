module Terrestrial
  class Web
    class Response
      def initialize(http_response)
        @inner_response = http_response
      end

      def success?
        @inner_response.code.to_s.start_with?("2")
      end

      def body
        JSON.parse(@inner_response.body)
      end
    end
  end
end
