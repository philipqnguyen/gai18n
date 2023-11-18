module GAI18n
  class LocaleFile
    extend Forwardable

    attr_reader :locale, :assistant_id, :skip_keys

    def_delegators :@locale, :lang, :root_key, :path, :source_lang,
                   :source_path, :source_root_key

    def initialize(locale)
      @locale = locale
      @assistant_id = GAI18n.config.openai_assistant_id
      @skip_keys = []
    end

    def translate(skip_keys = [])
      @skip_keys = skip_keys
      write_file and return if translatable_key_values.empty?
      thread = GAI18n::OpenAI::Thread.create
      OpenAI::Message.create thread_id: thread.id, content: message_content
      run = OpenAI::Run.create assistant_id: assistant_id, thread_id: thread.id
      run = run.wait_until_done
      if run.requires_action?
        run.accept_translations.each {|translation| insert translation}
        write_file
        locale_file = self.class.new locale
        locale_file.translate(skip_keys + translatable_keys)
      else
        msg = ['Either the Run took too long or received incorrect',
               "Run status from OpenAI: #{run.status}"].join(' ')
        raise IncorrectResponseError, msg
      end
    end

    private

    def insert(translated_hash)
      content.deep_merge!(translated_hash)
    end

    def write_file
      ordered_content = source_content.deep_merge!(content.to_h)
      filtered_content = undeleted_content ordered_content.to_h, content.to_h
      content_yaml = {root_key.to_s => filtered_content}.to_yaml
      file_path = if path.start_with? '/'
        path
      else
        GAI18n.config.project_root.join(path)
      end
      File.open(file_path, 'w') { |f| f.write content_yaml }
    end

    def translatable_key_values
      @translatable_key_values ||= translatable_keys.map do |key|
        [key, source_content.value_for(key)]
      end.to_h
    end

    def translatable_keys
      @_translatable_keys ||= begin
        keys = source_content.keys - content.keys + keys_with_changed_values - skip_keys
        keys.first GAI18n.config.keys_per_paginated_requests
      end
    end

    def keys_with_changed_values
      GitComparison.new(self).changes
    end

    def deep_merge(first, second)
      merger = proc do |key, v1, v2|
        if Hash === v1 && Hash === v2
          v1.merge(v2, &merger)
        else
          v2
        end
      end
      first.merge(second, &merger)
    end

    def source_content
      @source_content ||= begin
        raw = YAML.load_file(source_path)[source_root_key.to_s]
        Content.new raw
      end
    end

    def content
      @content ||= begin
        raw_content = if File.exist?(path)
          raw_content = YAML.load_file(path)
          raw_content.respond_to?(:[]) ? raw_content[root_key.to_s] : {}
        else
          {}
        end
        Content.new undeleted_content(raw_content, source_content.to_h)
      end
    end

    def undeleted_content(first_content, second_content)
      first_content.each_with_object({}) do |(key, value), new_hash|
        if second_content.key?(key)
          new_hash[key] = value.is_a?(Hash) ? undeleted_content(value, second_content[key]) : value
        end
      end
    end

    def message_content
      <<~HEREDOC
        Below are keys and values. Please translate the values from #{source_lang} to #{lang}, then submit the translations.

        ```
        #{translatable_key_values.map {|key, val| "#{key}: #{val}"}.join("\n")}
        ```
      HEREDOC
    end
  end
end
