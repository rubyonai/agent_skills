# frozen_string_literal: true

require "yaml"

module AgentSkills
  class Skill
    FRONTMATTER_REGEX = /\A---\s*\n(.+?)\n---\s*\n(.*)/m

    attr_reader :path, :name, :description, :license, :compatibility,
                :metadata, :allowed_tools, :body

    def initialize(path:, name:, description:, body:, license: nil,
                   compatibility: nil, metadata: {}, allowed_tools: [])
      @path = path
      @name = name
      @description = description
      @body = body
      @license = license
      @compatibility = compatibility
      @metadata = metadata
      @allowed_tools = allowed_tools
    end

    def self.load(skill_path)
      skill_md_path = File.join(skill_path, "SKILL.md")

      unless File.exist?(skill_md_path)
        raise NotFoundError, "SKILL.md not found in #{skill_path}"
      end

      content = File.read(skill_md_path, encoding: "UTF-8")
      parse(content, skill_path)
    end

    def self.parse(content, path = nil)
      match = content.match(FRONTMATTER_REGEX)

      unless match
        raise ParseError, "Invalid SKILL.md format: missing YAML frontmatter"
      end

      frontmatter = YAML.safe_load(match[1], symbolize_names: true)
      body = match[2].strip

      new(
        path: path,
        name: frontmatter[:name],
        description: frontmatter[:description],
        license: frontmatter[:license],
        compatibility: frontmatter[:compatibility],
        metadata: frontmatter[:metadata] || {},
        allowed_tools: parse_allowed_tools(frontmatter[:"allowed-tools"]),
        body: body
      )
    end

    def scripts
      return [] unless @path

      Dir.glob(File.join(@path, "scripts", "*")).select { |f| File.file?(f) }
    end

    def references
      return [] unless @path

      Dir.glob(File.join(@path, "references", "*.md"))
    end

    def assets
      return [] unless @path

      Dir.glob(File.join(@path, "assets", "*")).select { |f| File.file?(f) }
    end

    def to_prompt_xml
      <<~XML.strip
        <skill name="#{@name}">
          <description>#{@description}</description>
          <instructions>
        #{@body}
          </instructions>
        </skill>
      XML
    end

    def to_h
      {
        name: @name,
        description: @description,
        license: @license,
        compatibility: @compatibility,
        metadata: @metadata,
        allowed_tools: @allowed_tools,
        body: @body
      }.compact
    end

    private

    def self.parse_allowed_tools(value)
      return [] if value.nil?

      value.to_s.split(/\s+/)
    end

    private_class_method :parse_allowed_tools
  end
end
