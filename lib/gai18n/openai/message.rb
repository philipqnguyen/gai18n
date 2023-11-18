module GAI18n
  module OpenAI
    class Message
      class << self
        def create(thread_id:, content:, uploads: [])
          openai_client = GAI18n.config.openai_client
          parameters = {
            role: 'user',
            content: content
          }
          response = openai_client.messages.create thread_id: thread_id,
                                                   parameters: parameters
          new response
        end

        def all(thread_id:)
          openai_client = GAI18n.config.openai_client
          response = openai_client.messages.list(thread_id: thread_id)
          response['data'].map { |message| new message }
        end
      end

      attr_reader :id, :object, :created_at, :role, :thread_id, :content,
                  :file_ids, :assistant_id, :run_id, :metadata

      def initialize(response)
        @id = response['id']
        @object = response['object']
        @created_at = response['created_at']
        @role = response['role']
        @thread_id = response['thread_id']
        @content = response['content']
        @file_ids = response['file_ids']
        @assisistant_id = response['assistant_id']
        @run_id = response['run_id']
        @metadata = response['metadata']
      end
    end
  end
end
