require 'optparse'

module GAI18n
  class CLI
    class Parser
      Options = Struct.new(:secret)

      def self.parse(options)
        args = Options.new

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: gai18n [setup|translate|assistant:create] [options]"

          if options[0] == 'setup'
            opts.on("-sSECRET", "--secret=SECRET", "OpenAI Secret Key") do |secret|
              args.secret = secret
            end
          end

          opts.on("-h", "--help", "Prints this help") do
            puts opts
            exit
          end
        end

        opt_parser.parse!(options)
        return args
      end
    end

    def run(argv)
      if argv[0] == 'setup'
        setup openai_api_key: Parser.parse(argv).secret
      elsif argv[0] == 'translate'
        translate
      elsif argv[0] == 'assistant:create'
        assistant_create
      else
        Parser.parse(argv + ['-h'])
      end
    end

    private

    def setup(openai_api_key: nil)
      GAI18n::Setup.new.run(openai_api_key: openai_api_key)
    end

    def translate
      require_config_file
      GAI18n::Translator.new.translate
    end

    def assistant_create
      require_config_file
      puts 'Creating OpenAI assistant...'
      assistant = GAI18n::OpenAI::Assistant.create
      puts 'Created OpenAI assistant.'
      puts 'Please add the following to your gai18n.rb config file.'
      puts 'GAI18n.configure do |config|'
      puts "  config.openai_assistant_id = '#{assistant.id}'"
      puts 'end'
    end

    def require_config_file
      if File.exist?('./config/gai18n.rb' )
        require './config/gai18n'
      elsif File.exist?('./gai18n.rb' )
        require './gai18n'
      else
        message = [
          'GAI18n configuration file not found.',
          'Ensure there is one at ./config/gai18n.rb or ./gai18n.rb'
        ].join(' ')
        raise GAI18n::LoadError, message
      end
    end
  end
end
