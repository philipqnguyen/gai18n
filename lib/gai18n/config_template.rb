GAI18n.configure do |config|
  config.source_locale = {
    english: {
      # `files`: this specifies where to match one or more source yml files.
      # Change this to match your source language file(s) location.
      files: 'config/**/en.yml',

      # `file_identifier`: this is used to specify the identifier for the
      # source language file. It could be a part of the file name or the entire
      # file path. This identifier is used by the gem to locate and process the
      # source language file. For example, if your source language file is
      # located at 'config/dashboards/en.yml' or 'config/en/dashboard.yml' you
      # should set `file_identifier` to 'en'.
      file_identifier: 'en',

      # `root_key`: this is the root key of the yaml content in your source
      #file(s). For example, if your root key in the source language file is
      # `en`, you should set `root_key` to 'en'.
      root_key: 'en'
    }
  }

  config.target_locales = {
    japanese: {
      # `file_identifier`: this is used to specify the identifier for the
      # target language file. It could be a part of the file name or the entire
      # file path. This identifier is used by the gem to locate and process the
      # target language file. For example, if your target language file is
      # located at 'config/dashboards/jp.yml' or 'config/jp/dashboard.yml' you
      # should set `file_identifier` to 'jp'.
      file_identifier: 'jp',

      # `root_key`: this is the root key of the yaml content in your source
      # file(s). For example, if your root key in the target language file is
      # `jp`, you should set `root_key` to 'jp'.
      root_key: 'jp'
    },
    french: {
      file_identifier: 'fr',
      root_key: 'fr'
    }
  }

  # `openai_secret_key`: this is the secret key from OpenAI. You can get this
  # from your OpenAI account.
  config.openai_secret_key = 'replace_with_the_openai_secret_key'

  # `base_git_branch`: we need the base branch to compare changes between the
  # current source file to the source file in the base branch. This is used to
  # determine the changes that need to be translated.
  config.base_git_branch = 'main'

  # `openai_assistant_id`: this is the assistant id from OpenAI. Please create
  # this assistant using the `bundle exec gai18n assistant:create` command.
  # Do not use an existing assisntant. This is because the assistant created
  # from the command is configured with specific instructions and tools that
  # are required for translation.
  config.openai_assistant_id = 'replace_with_the_assistant_id'
end
