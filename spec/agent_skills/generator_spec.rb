# frozen_string_literal: true

require "tmpdir"

RSpec.describe AgentSkills::Generator do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  describe ".create" do
    it "creates skill directory" do
      path = described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill"
      )

      expect(File.directory?(path)).to be true
      expect(path).to eq(File.join(tmpdir, "my-skill"))
    end

    it "creates SKILL.md with correct content" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill"
      )

      skill_md = File.read(File.join(tmpdir, "my-skill", "SKILL.md"))

      expect(skill_md).to include("name: my-skill")
      expect(skill_md).to include("description: A test skill")
      expect(skill_md).to include("# My Skill")
    end

    it "creates scripts directory when with_scripts is true" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill",
        with_scripts: true
      )

      expect(File.directory?(File.join(tmpdir, "my-skill", "scripts"))).to be true
    end

    it "creates references directory when with_references is true" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill",
        with_references: true
      )

      expect(File.directory?(File.join(tmpdir, "my-skill", "references"))).to be true
    end

    it "creates assets directory when with_assets is true" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill",
        with_assets: true
      )

      expect(File.directory?(File.join(tmpdir, "my-skill", "assets"))).to be true
    end

    it "raises ArgumentError when name is missing" do
      expect {
        described_class.create(path: tmpdir, name: nil, description: "Test")
      }.to raise_error(ArgumentError, "name is required")
    end

    it "raises ArgumentError when description is missing" do
      expect {
        described_class.create(path: tmpdir, name: "test", description: nil)
      }.to raise_error(ArgumentError, "description is required")
    end

    it "creates valid skill that can be loaded" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill"
      )

      skill = AgentSkills::Skill.load(File.join(tmpdir, "my-skill"))

      expect(skill.name).to eq("my-skill")
      expect(skill.description).to eq("A test skill")
    end

    it "creates valid skill that passes validation" do
      described_class.create(
        path: tmpdir,
        name: "my-skill",
        description: "A test skill"
      )

      skill = AgentSkills::Skill.load(File.join(tmpdir, "my-skill"))
      validator = AgentSkills::Validator.new(skill)

      expect(validator.valid?).to be true
    end
  end
end
