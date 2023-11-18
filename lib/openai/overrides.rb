
if ENV['ENABLE_OPENAI_LOGS'] == 'true'
  module OpenAI
    module HTTP
      def conn(multipart: false)
        Faraday.new do |f|
          f.options[:timeout] = @request_timeout
          f.request(:multipart) if multipart
          f.response :raise_error
          f.response :json
          f.response :logger, ::Logger.new(STDOUT), bodies: true
        end
      end
    end
  end
end
