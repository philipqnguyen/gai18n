module GAI18n
  module OpenAI
    class Run
      class << self
        def create(assistant_id:, thread_id:)
          openai_client = GAI18n.config.openai_client
          parameters = {assistant_id: assistant_id}
          response = openai_client.runs.create thread_id: thread_id,
                                               parameters: parameters
          new response
        end

        def find(thread_id:, id:)
          openai_client = GAI18n.config.openai_client
          response = openai_client.runs.retrieve thread_id: thread_id, id: id
          new response
        end
      end

      attr_accessor :id, :object, :created_at, :assistant_id, :thread_id,
                   :status, :started_at, :expires_at, :cancelled_at, :failed_at,
                   :completed_at, :last_error, :model, :instructions, :tools,
                   :file_ids, :metadata, :tool_calls

      def initialize(response)
        set_attributes_from(response)
      end

      def completed?
        status == 'completed'
      end

      def requires_action?
        status == 'requires_action'
      end

      def failed?
        status == 'failed'
      end

      def cancelled?
        status == 'cancelled'
      end

      def expired?
        status == 'expired'
      end

      def accept_translations
        submit_tool_outputs
        submit_translations
      end

      def reload
        openai_client = GAI18n.config.openai_client
        response = openai_client.runs.retrieve thread_id: thread_id, id: id
        set_attributes_from response
      end

      def wait_until_done(count = 0)
        return self if count > 10
        reload
        halt_statuses = %w[requires_action completed failed cancelled expired]
        return self if halt_statuses.include? status
        sleep 5
        wait_until_done count + 1
      end

      private

      def set_attributes_from(response)
        @id = response['id']
        @object = response['object']
        @created_at = response['created_at']
        @assistant_id = response['assistant_id']
        @thread_id = response['thread_id']
        @status = response['status']
        @started_at = response['started_at']
        @expires_at = response['expires_at']
        @cancelled_at = response['cancelled_at']
        @failed_at = response['failed_at']
        @completed_at = response['completed_at']
        @last_error = response['last_error']
        @model = response['model']
        @instructions = response['instructions']
        @tools = response['tools']
        @file_ids = response['file_ids']
        @metadata = response['metadata']
        required_action = response.fetch('required_action', {}) || {}
        submit_tool_outputs = required_action.fetch('submit_tool_outputs', {})
        @tool_calls = submit_tool_outputs.fetch('tool_calls', [])
      end

      def submit_tool_outputs
        parameters = tool_calls.inject({tool_outputs: []}) do |hash, tool_call|
          hash[:tool_outputs] << {
            tool_call_id: tool_call['id'],
            output: "Accepted"
          }
          hash
        end
        openai_client = GAI18n.config.openai_client
        openai_client.runs.submit_tool_outputs run_id: id,
                                               thread_id: thread_id,
                                               parameters: parameters
      end

      def submit_translations
        tool_calls.map do |tool_call|
          args = JSON.parse(tool_call["function"]["arguments"]).transform_keys(&:to_sym)
          Translation.new.submit **args
        end
      end
    end
  end
end
