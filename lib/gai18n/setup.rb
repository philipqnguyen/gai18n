module GAI18n
  class Setup
    def run(openai_api_key: nil)
      copy_template
      puts "GAI18n configuration file created at #{destination}"
      if openai_api_key
        add_api_key_to_template openai_api_key
        puts 'Added OpenAI API key to configuration file.'
        puts 'Please run `bundle exec gai18n assistant:create` to create an OpenAI assistant, and then add the assistant id to the configuration file.'
      else
        puts '1. Please add your OpenAI API key to the configuration file.'
        puts '2. Then run `bundle exec gai18n assistant:create` to create an OpenAI assistant, and then add the assistant id to the configuration file.'
      end
    end

    private

    def destination
      if File.directory?('./config')
        "#{GAI18n.config.project_root}/config/gai18n.rb"
      else
        "#{GAI18n.config.project_root}/gai18n.rb"
      end
    end

    def copy_template
      template_file = File.expand_path '../config_template.rb', __FILE__
      FileUtils.cp template_file, destination
    end

    def add_api_key_to_template(openai_api_key)
      content = File.read(destination).gsub('replace_with_the_openai_secret_key', openai_api_key)
      File.open(destination, 'w') do |file|
        file.write content
      end
    end
  end
end
