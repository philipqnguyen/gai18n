module GAI18n
  class Translation
    def submit(key:, translation:, language:)
      arr = key.split('.') + [translation]
      result = arr.reverse.inject({}) do |hash, k|
        if k == translation
          k
        else
          { k => hash }
        end
      end
      result
    end
  end
end
