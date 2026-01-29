# frozen_string_literal: true

require "thor"

module AgentSkills
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "new NAME", "Create a new skill"
    option :description, aliases: "-d", required: true, desc: "Skill description"
    option :path, aliases: "-p", default: ".", desc: "Output directory"
    option :scripts, type: :boolean, default: false, desc: "Include scripts directory"
    option :references, type: :boolean, default: false, desc: "Include references directory"
    option :assets, type: :boolean, default: false, desc: "Include assets directory"
    def new(name)
      path = Generator.create(
        path: options[:path],
        name: name,
        description: options[:description],
        with_scripts: options[:scripts],
        with_references: options[:references],
        with_assets: options[:assets]
      )

      say "Created skill at #{path}/", :green
      say "  SKILL.md"
      say "  scripts/" if options[:scripts]
      say "  references/" if options[:references]
      say "  assets/" if options[:assets]
    end

    desc "validate PATH", "Validate a skill against the spec"
    def validate(path)
      skill = Skill.load(path)
      validator = Validator.new(skill)

      if validator.valid?
        say "#{skill.name} is valid", :green
      else
        say "#{skill.name} has errors:", :red
        validator.errors.each { |e| say "  - #{e}", :red }
        exit 1
      end
    rescue NotFoundError, ParseError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    desc "list", "List discovered skills"
    option :path, aliases: "-p", type: :array, desc: "Paths to search"
    def list
      paths = options[:path] || Loader::DEFAULT_PATHS
      loader = Loader.new(paths: paths)
      skills = loader.discover

      if skills.empty?
        say "No skills found in: #{paths.join(', ')}", :yellow
        return
      end

      say "Found #{skills.size} skill(s):\n\n"

      skills.each do |name, skill|
        say name, :green
        say "  #{truncate(skill.description, 60)}"
        say "  Path: #{skill.path}" if skill.path
        say ""
      end
    end

    desc "info PATH", "Show detailed skill information"
    def info(path)
      skill = Skill.load(path)

      say "Name:        ", :green, false
      say skill.name
      say "Description: ", :green, false
      say skill.description
      say "Path:        ", :green, false
      say skill.path || "(none)"

      if skill.license
        say "License:     ", :green, false
        say skill.license
      end

      if skill.compatibility
        say "Compat:      ", :green, false
        say skill.compatibility
      end

      unless skill.scripts.empty?
        say "Scripts:     ", :green, false
        say skill.scripts.map { |s| File.basename(s) }.join(", ")
      end

      unless skill.references.empty?
        say "References:  ", :green, false
        say skill.references.map { |r| File.basename(r) }.join(", ")
      end

      # Validation status
      validator = Validator.new(skill)
      say "Valid:       ", :green, false
      say validator.valid? ? "Yes" : "No (#{validator.errors.join(', ')})"
    rescue NotFoundError, ParseError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    desc "pack PATH", "Package a skill into a .skill file"
    option :output, aliases: "-o", desc: "Output file path"
    def pack(path)
      output = Packager.pack(path, output: options[:output])
      say "Created #{output}", :green
    rescue NotFoundError, ParseError, ValidationError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    desc "unpack FILE", "Extract a .skill file"
    option :output, aliases: "-o", default: ".", desc: "Output directory"
    def unpack(file)
      extracted = Packager.unpack(file, output: options[:output])
      say "Extracted to #{extracted}", :green
    rescue NotFoundError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    desc "version", "Show version"
    def version
      say "agent_skills #{VERSION}"
    end

    private

    def truncate(text, length)
      return text if text.length <= length

      "#{text[0, length - 3]}..."
    end
  end
end
