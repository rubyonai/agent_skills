# frozen_string_literal: true

require "tmpdir"

RSpec.describe AgentSkills::Loader do
  let(:tmpdir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(tmpdir) }

  def create_skill(name, description)
    AgentSkills::Generator.create(
      path: tmpdir,
      name: name,
      description: description
    )
  end

  describe "#discover" do
    it "finds skills in specified paths" do
      create_skill("skill-one", "First skill")
      create_skill("skill-two", "Second skill")

      loader = described_class.new(paths: [tmpdir])
      skills = loader.discover

      expect(skills.keys).to contain_exactly("skill-one", "skill-two")
    end

    it "returns empty hash when no skills found" do
      loader = described_class.new(paths: [tmpdir])
      skills = loader.discover

      expect(skills).to be_empty
    end

    it "skips non-existent paths" do
      loader = described_class.new(paths: ["/nonexistent/path"])
      skills = loader.discover

      expect(skills).to be_empty
    end

    it "loads skill objects correctly" do
      create_skill("my-skill", "A test skill")

      loader = described_class.new(paths: [tmpdir])
      loader.discover

      skill = loader["my-skill"]

      expect(skill).to be_a(AgentSkills::Skill)
      expect(skill.name).to eq("my-skill")
      expect(skill.description).to eq("A test skill")
    end
  end

  describe "#[]" do
    it "returns skill by name" do
      create_skill("my-skill", "A test skill")

      loader = described_class.new(paths: [tmpdir])
      loader.discover

      expect(loader["my-skill"].name).to eq("my-skill")
    end

    it "returns nil for unknown skill" do
      loader = described_class.new(paths: [tmpdir])
      loader.discover

      expect(loader["unknown"]).to be_nil
    end
  end

  describe "#count" do
    it "returns number of discovered skills" do
      create_skill("skill-one", "First")
      create_skill("skill-two", "Second")

      loader = described_class.new(paths: [tmpdir])
      loader.discover

      expect(loader.count).to eq(2)
    end
  end

  describe "#each" do
    it "iterates over skills" do
      create_skill("skill-one", "First")
      create_skill("skill-two", "Second")

      loader = described_class.new(paths: [tmpdir])
      loader.discover

      names = []
      loader.each { |name, _skill| names << name }

      expect(names).to contain_exactly("skill-one", "skill-two")
    end
  end

  describe "#find_relevant" do
    before do
      create_skill("expense-parser", "Parse expense receipts and invoices")
      create_skill("code-reviewer", "Review code for best practices")
      create_skill("doc-generator", "Generate documentation from code")
    end

    let(:loader) do
      l = described_class.new(paths: [tmpdir])
      l.discover
      l
    end

    it "finds skills matching query keywords" do
      results = loader.find_relevant("parse receipts")

      expect(results.map(&:name)).to include("expense-parser")
    end

    it "matches against skill name" do
      results = loader.find_relevant("expense")

      expect(results.map(&:name)).to include("expense-parser")
    end

    it "matches against description" do
      results = loader.find_relevant("documentation")

      expect(results.map(&:name)).to include("doc-generator")
    end

    it "returns empty array for no matches" do
      results = loader.find_relevant("unrelated query")

      expect(results).to be_empty
    end

    it "returns empty array for nil query" do
      expect(loader.find_relevant(nil)).to be_empty
    end

    it "returns empty array for empty query" do
      expect(loader.find_relevant("")).to be_empty
    end
  end
end
