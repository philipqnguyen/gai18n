module GAI18n
  class Configuration
    attr_accessor :source_locale, :openai_secret_key, :locales,
                  :openai_assistant_id, :target_locales

    attr_writer :base_git_branch, :model, :keys_per_paginated_requests

    def openai_client
      args = {
        access_token: openai_secret_key
      }
      @openai_client ||= ::OpenAI::Client.new args
    end

    def project_root
      return Rails.root if defined? Rails
      return Bundler.root if defined? Bundler
      Dir.pwd
    end

    def base_git_branch
      @base_git_branch ||= 'main'
    end

    def model
      @model ||= 'gpt-3.5-turbo-1106'
    end

    def keys_per_paginated_requests
      @keys_per_paginated_requests ||= 20
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.config
    configuration
  end

  def self.configure
    yield configuration if block_given?
  end
end
