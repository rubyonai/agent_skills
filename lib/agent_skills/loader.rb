# frozen_string_literal: true

module AgentSkills
  class Loader
    DEFAULT_PATHS = [
      File.expand_path("~/.config/claude/skills"),
      ".claude/skills",
      "skills"
    ].freeze

    attr_reader :paths, :skills

    def initialize(paths: DEFAULT_PATHS)
      @paths = Array(paths)
      @skills = {}
    end

    def discover
      @skills = {}

      @paths.each do |base_path|
        expanded = File.expand_path(base_path)
        next unless File.directory?(expanded)

        discover_in_path(expanded)
      end

      @skills
    end

    def [](name)
      @skills[name]
    end

    def count
      @skills.size
    end

    def each(&block)
      @skills.each(&block)
    end

    def find_relevant(query)
      return [] if query.nil? || query.empty?

      keywords = query.downcase.split(/\s+/)

      @skills.values.select do |skill|
        text = "#{skill.name} #{skill.description}".downcase
        keywords.any? { |keyword| text.include?(keyword) }
      end
    end

    private

    def discover_in_path(base_path)
      Dir.glob(File.join(base_path, "*", "SKILL.md")).each do |skill_md|
        skill_dir = File.dirname(skill_md)

        begin
          skill = Skill.load(skill_dir)
          @skills[skill.name] = skill
        rescue Error => e
          warn "Warning: Failed to load skill at #{skill_dir}: #{e.message}"
        end
      end
    end
  end
end
