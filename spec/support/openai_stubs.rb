module OpenAIStubs
  def api_root
    "https://api.openai.com/v1"
  end

  def post_thread_stub(thread_ids:)
    stub_request(:post, "#{api_root}/threads").with(
      headers: {content_type: 'application/json'}
    ).to_return(
      thread_ids.map do |thread_id|
        {
          status: 200,
          headers: {content_type: 'application/json'},
          body: {
            id: thread_id,
            object: "thread",
            created_at: 1703372321,
            metadata: {}
          }.to_json,
        }
      end
    )
  end

  def post_message_stub(thread_id:, untranslated_keys_values:)
    key_str = untranslated_keys_values.inject("") { |str, (k, v)| str << "\n#{k}: #{v}" }
    url = "#{api_root}/threads/#{thread_id}/messages"
      stub_request(:post, url).with(
        headers: {content_type: 'application/json'},
        body: {
          role: 'user',
          content: "Below are keys and values. Please translate the values from english to japanese, then submit the translations.\n\n```#{key_str}\n```\n"
        }.to_json,
      ).to_return(
        status: 200,
        headers: {content_type: 'application/json'},
        body: {
          id: "msg_1hlWvIuWZ722ML410zNqDkY6",
          object: "thread.message",
          created_at: 1703372321,
          thread_id: thread_id,
          role: "user",
          content: [
            {
              type: "text",
              text: {
                value: "Below are keys and values. Please translate the values from english to japanese, then submit the translations.\n\n```#{key_str}\n```\n",
                annotations: []
              }
            }
          ],
          file_ids: [],
          assistant_id: nil,
          run_id: nil,
          metadata: {}
        }.to_json,
      )
  end

  def post_run_stub(run_id:, thread_id:, assistant_id:)
    stub_request(:post, "#{api_root}/threads/#{thread_id}/runs").with(
      headers: {content_type: 'application/json'},
      body: {
        assistant_id: assistant_id
      }.to_json,
    ).to_return(
      status: 200,
      headers: {content_type: 'application/json'},
      body: {
        id: run_id,
        object: "thread.run",
        created_at: 1703372321,
        assistant_id: assistant_id,
        thread_id: thread_id,
        status: "queued",
        started_at: nil,
        expires_at: 1703372921,
        cancelled_at: nil,
        failed_at: nil,
        completed_at: nil,
        last_error: nil,
        model: "gpt-3.5-turbo-1106",
        instructions: "You are a software localization engineer. You have been tasked with translating the English source to the target language. You will be given a key and a source string. You will be asked to translate the source string to the target language. Once translated, please call the translation.submit function with the key, translated string, and target language.",
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
                required: [
                  "key",
                  "translation",
                  "language"
                ]
              }
            }
          }
        ],
        file_ids: [],
        metadata: {}
      }.to_json,
    )
  end

  def get_run_in_progress_stub(thread_id:, assistant_id:, run_id:)
    url = "#{api_root}/threads/#{thread_id}/runs/#{run_id}"
    stub_request(:get, url).with(
      headers: {content_type: 'application/json'}
    ).to_return(
      status: 200,
      headers: {content_type: 'application/json'},
      body: {
        id: run_id,
        object: "thread.run",
        created_at: 1703372321,
        assistant_id: assistant_id,
        thread_id: thread_id,
        status: "in_progress",
        started_at: nil,
        expires_at: 1703372921,
        cancelled_at: nil,
        failed_at: nil,
        completed_at: nil,
        required_action: nil,
        last_error: nil,
        model: "gpt-3.5-turbo-1106",
        instructions: "You are a software localization engineer. You have been tasked with translating the English source to the target language. You will be given a key and a source string. You will be asked to translate the source string to the target language. Once translated, please call the translation.submit function with the key, translated string, and target language.",
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
                required: [
                  "key",
                  "translation",
                  "language"
                ]
              }
            }
          }
        ],
        file_ids: [],
        metadata: {}
      }.to_json,
    )
  end

  def get_run_requires_action_stub(thread_id:, assistant_id:, run_id:, translated_keys_values:)
    tool_calls = translated_keys_values.map do |k, v|
      {
        id: "call_#{k}",
        type: "function",
        function: {
          name: "translation.submit",
          arguments: "{\"key\": \"#{k}\", \"translation\": \"#{v}\", \"language\": \"jp\"}"
        }
      }
    end
    url = "#{api_root}/threads/#{thread_id}/runs/#{run_id}"
    stub_request(:get, url).with(
      headers: {content_type: 'application/json'}
    ).to_return(
      status: 200,
      headers: {content_type: 'application/json'},
      body: {
        id: run_id,
        object: "thread.run",
        created_at: 1703372321,
        assistant_id: assistant_id,
        thread_id: thread_id,
        status: "requires_action",
        started_at: 1703372318,
        expires_at: 1703372918,
        cancelled_at: nil,
        failed_at: nil,
        completed_at: nil,
        required_action: {
          type: "submit_tool_outputs",
          submit_tool_outputs: {
            tool_calls: tool_calls
          }
        },
        last_error: nil,
        model: "gpt-3.5-turbo-1106",
        instructions: "You are a software localization engineer. You have been tasked with translating the English source to the target language. You will be given a key and a source string. You will be asked to translate the source string to the target language. Once translated, please call the translation.submit function with the key, translated string, and target language.",
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
                required: [
                  "key",
                  "translation",
                  "language"
                ]
              }
            }
          }
        ],
        file_ids: [],
        metadata: {}
      }.to_json,
    )
  end

  def post_submit_tool_output_stub(thread_id:, run_id:, assistant_id:, translated_keys_values:)
    tool_outputs = translated_keys_values.map do |k, v|
      {
        tool_call_id: "call_#{k}",
        output: "Accepted"
      }
    end
    url = "#{api_root}/threads/#{thread_id}/runs/#{run_id}/submit_tool_outputs"
    stub_request(:post, url).with(
      headers: {content_type: 'application/json'},
      body: {
        tool_outputs: tool_outputs
      }.to_json
    ).to_return(
      status: 200,
      headers: {content_type: 'application/json'},
      body: {
        id: "run_zzRWENvOsuFkWgy2DCANYzOR",
        object: "thread.run",
        created_at: 1703372318,
        assistant_id: assistant_id,
        thread_id: "thread_OYsSbr9tsL05sRyhhoL2p2y0",
        status: "queued",
        started_at: 1703372318,
        expires_at: 1703372918,
        cancelled_at: nil,
        failed_at: nil,
        completed_at: nil,
        last_error: nil,
        model: "gpt-3.5-turbo-1106",
        instructions: "You are a software localization engineer. You have been tasked with translating the English source to the target language. You will be given a key and a source string. You will be asked to translate the source string to the target language. Once translated, please call the translation.submit function with the key, translated string, and target language.",
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
                required: [
                  "key",
                  "translation",
                  "language"
                ]
              }
            }
          }
        ],
        file_ids: [],
        metadata: {}
      }.to_json,
    )
  end
end
