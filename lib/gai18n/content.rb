module GAI18n
  class Content
    attr_reader :current

    def initialize(raw)
      @current = raw
    end

    def deep_merge!(second)
      merger = proc do |key, v1, v2|
        if Hash === v1 && Hash === v2
          v1.merge!(v2, &merger)
        else
          v2
        end
      end
      current.merge!(second, &merger)
      self
    end

    def to_h
      current
    end

    def keys
      flatten_keys current
    end

    def value_for(key)
      keys = key.split('.')
      keys.inject(current) do |hash, key|
        hash[key]
      end
    end

    private

    def flatten_keys(hash, prefix = nil)
      hash.flat_map do |key, value|
        if value.is_a? Hash
          flatten_keys(value, prefix ? "#{prefix}.#{key}" : key)
        else
          prefix ? "#{prefix}.#{key}" : key
        end
      end
    end
  end
end
