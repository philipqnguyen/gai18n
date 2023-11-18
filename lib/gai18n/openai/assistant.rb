module GAI18n
  module OpenAI
    class Assistant
      class << self
        def create
          description = ['This assisistant was created by GAI18n',
                        'to help with internationalization.'].join ' '
          instructions = "You are a software localization engineer. You have been tasked with translating the English source to the target language. You will be given a key and a source string. You will be asked to translate the source string to the target language. Once translated, please call the translation.submit function with the key, translated string, and the target language. If you are asked to translate into multiple target languages, please call the translation.submit function for each target language."
          openai_client = GAI18n.config.openai_client
          model = GAI18n.config.model
          parameters = {
            model: model,
            name: "GAI18n-#{Time.now.to_i}",
            description: description,
            instructions: instructions,
            tools: [
              {
                type: "function",
                function: {
                  name: "translation.submit",
                  description: "Submit a translation",
                  parameters: {
                    type: "object",
                    properties: {
                      key: {
                        type: "string",
                        description: "The given key that's associated to the string needing translation."
                      },
                      translation: {
                        type: "string",
                        description: "The translated string."
                      },
                      language: {
                        type: "string",
                        description: "The language of the translation."
                      }
                    },
                    required: ["key", "translation", "language"]
                  }
                }
              }
            ]
          }
          response = openai_client.assistants.create parameters: parameters
          new response
        end

        def find(id)
          openai_client = GAI18n.config.openai_client
          response = openai_client.assistants.retrieve id: id
          new response
        end
      end

      attr_reader :id, :object, :created_at, :name, :description,
                  :model, :instructions, :tools, :file_ids, :metadata

      def initialize(response)
        @id = response['id']
        @object = response['object']
        @created_at = response['created_at']
        @name = response['name']
        @description = response['description']
        @model = response['model']
        @instructions = response['instructions']
        @tools = response['tools']
        @file_ids = response['file_ids']
        @metadata = response['metadata']
      end
    end
  end
end
