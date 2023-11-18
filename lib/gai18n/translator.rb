module GAI18n
  class Translator
    def translate
      threads = Locale.target_locale_files.map do |target_locale_file|
        Thread.new { target_locale_file.translate }
      end
      threads.each(&:join)
    end
  end
end
