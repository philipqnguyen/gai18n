module GAI18n
  class GitComparison
    attr_reader :base_git_branch, :project_root, :source_path, :source_root_key

    def initialize(locale_file)
      @base_git_branch = GAI18n.config.base_git_branch
      @project_root = GAI18n.config.project_root
      @source_path = locale_file.source_path
      @source_root_key = locale_file.source_root_key
    end

    def changes
      git = Git.open(project_root, :log => Logger.new(STDOUT))
      diff = git.diff(base_git_branch).path(source_path)
      base_content = diff.first&.blob(:src)&.contents
      return [] if base_content.nil?
      base_yaml = YAML.load(base_content)[source_root_key.to_s]
      current_yaml = YAML.load_file(source_path)[source_root_key.to_s]
      keys_with_changed_values(base_yaml, current_yaml)
    end

    private

    def keys_with_changed_values(base_yaml, current_yaml, prefix = '')
      base_yaml.keys.inject([]) do |keys, key|
        full_key = prefix.empty? ? key : "#{prefix}.#{key}"
        if base_yaml[key] != current_yaml[key]
          if base_yaml[key].is_a?(Hash) && current_yaml[key].is_a?(Hash)
            keys.concat(keys_with_changed_values(base_yaml[key], current_yaml[key], full_key))
          else
            keys << full_key
          end
        end
        keys
      end
    end
  end
end
