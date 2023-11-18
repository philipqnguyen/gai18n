module GAI18n
  class GAI18nError < StandardError; end
  class IncorrectResponseError < GAI18nError; end
  class LoadError < GAI18nError; end
end
