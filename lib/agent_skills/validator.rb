# frozen_string_literal: true

module AgentSkills
  class Validator
    NAME_REGEX = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
    MAX_NAME_LENGTH = 64
    MAX_DESCRIPTION_LENGTH = 1024
    MAX_COMPATIBILITY_LENGTH = 500

    attr_reader :skill, :errors

    def initialize(skill)
      @skill = skill
      @errors = []
    end

    def valid?
      @errors = []
      validate_name
      validate_description
      validate_compatibility
      validate_directory_match
      @errors.empty?
    end

    def self.validate!(skill)
      validator = new(skill)
      return skill if validator.valid?

      raise ValidationError, validator.errors.join(", ")
    end

    private

    def validate_name
      name = @skill.name.to_s

      if name.empty?
        @errors << "name is required"
        return
      end

      if name.length > MAX_NAME_LENGTH
        @errors << "name must be #{MAX_NAME_LENGTH} characters or less"
      end

      unless name.match?(NAME_REGEX)
        @errors << "name must contain only lowercase letters, numbers, and hyphens"
      end

      if name.start_with?("-") || name.end_with?("-")
        @errors << "name cannot start or end with a hyphen"
      end

      if name.include?("--")
        @errors << "name cannot contain consecutive hyphens"
      end
    end

    def validate_description
      description = @skill.description.to_s

      if description.empty?
        @errors << "description is required"
        return
      end

      if description.length > MAX_DESCRIPTION_LENGTH
        @errors << "description must be #{MAX_DESCRIPTION_LENGTH} characters or less"
      end
    end

    def validate_compatibility
      compatibility = @skill.compatibility.to_s
      return if compatibility.empty?

      if compatibility.length > MAX_COMPATIBILITY_LENGTH
        @errors << "compatibility must be #{MAX_COMPATIBILITY_LENGTH} characters or less"
      end
    end

    def validate_directory_match
      return unless @skill.path

      dir_name = File.basename(@skill.path)
      return if dir_name == @skill.name

      @errors << "name '#{@skill.name}' must match directory name '#{dir_name}'"
    end
  end
end
