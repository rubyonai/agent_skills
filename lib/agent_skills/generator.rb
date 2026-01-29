# frozen_string_literal: true

require "fileutils"

module AgentSkills
  class Generator
    SKILL_TEMPLATE = <<~SKILL
      ---
      name: %<name>s
      description: %<description>s
      ---

      # %<title>s

      ## Instructions

      [Add step-by-step instructions here]

      ## Examples

      ### Input
      [Example input]

      ### Output
      [Expected output]

      ## Guidelines

      - [Add guidelines here]
    SKILL

    attr_reader :path, :name, :description, :options

    def initialize(path:, name:, description:, **options)
      @path = path
      @name = name
      @description = description
      @options = options
    end

    def self.create(path:, name:, description:, **options)
      new(path: path, name: name, description: description, **options).create
    end

    def create
      validate_inputs!
      create_directories
      create_skill_md
      skill_path
    end

    private

    def validate_inputs!
      raise ArgumentError, "name is required" if @name.nil? || @name.empty?
      raise ArgumentError, "description is required" if @description.nil? || @description.empty?
    end

    def skill_path
      File.join(@path, @name)
    end

    def create_directories
      FileUtils.mkdir_p(skill_path)
      FileUtils.mkdir_p(File.join(skill_path, "scripts")) if @options[:with_scripts]
      FileUtils.mkdir_p(File.join(skill_path, "references")) if @options[:with_references]
      FileUtils.mkdir_p(File.join(skill_path, "assets")) if @options[:with_assets]
    end

    def create_skill_md
      content = format(
        SKILL_TEMPLATE,
        name: @name,
        description: @description,
        title: titleize(@name)
      )

      File.write(File.join(skill_path, "SKILL.md"), content)
    end

    def titleize(name)
      name.split("-").map(&:capitalize).join(" ")
    end
  end
end
