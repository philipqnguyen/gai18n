module GAI18n
  class Locale
    class << self
      def source_locale
        GAI18n.config.source_locale
      end

      def source_language
        source_locale.keys.first
      end

      def source_file_identifier
        source_locale[source_language][:file_identifier]
      end

      def source_paths
        Dir.glob(source_locale[source_language][:files])
      end

      def source_root_key
        source_locale[source_language][:root_key] || source_file_identifier
      end

      def target_locale_files
        target_locales = GAI18n.config.target_locales
        target_locales.flat_map do |(lang, options)|
          source_paths.map do |source_path|
            file_identifier = options[:file_identifier]
            root_key = options[:root_key] || file_identifier
            path = source_path.gsub source_file_identifier, file_identifier
            Locale.new lang: lang,
                       root_key: root_key,
                       path: path,
                       source_lang: source_language,
                       source_path: source_path,
                       source_root_key: source_root_key
          end
        end
      end
    end

    attr_reader :lang, :root_key, :path, :file_identifier, :source_lang,
                :source_path, :source_root_key, :source_file_identifier,
                :locale_file_class

    def initialize(lang:, root_key:, path:, source_lang:, source_path:,
                   source_root_key:)
      @lang = lang
      @root_key = root_key
      @path = path
      @source_lang = source_lang
      @source_path = source_path
      @source_root_key = source_root_key
    end

    def translate
      LocaleFile.new(self).translate
    end
  end
end
