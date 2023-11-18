module GAI18n
  module OpenAI
    class Thread
      class << self
        def create
          openai_client = GAI18n.config.openai_client
          response = openai_client.threads.create
          new response
        end

      end

      attr_reader :id, :object, :created_at, :metadata

      def initialize(response)
        @id = response['id']
        @object = response['object']
        @created_at = response['created_at']
        @metadata = response['metadata']
      end
    end
  end
end
