# frozen_string_literal: true

RSpec.describe AgentSkills::Skill do
  describe ".load" do
    context "with a valid skill" do
      let(:skill) { described_class.load(fixture_path("valid-skill")) }

      it "parses the name" do
        expect(skill.name).to eq("valid-skill")
      end

      it "parses the description" do
        expect(skill.description).to include("valid test skill")
      end

      it "parses the license" do
        expect(skill.license).to eq("MIT")
      end

      it "parses compatibility" do
        expect(skill.compatibility).to eq("Requires Ruby 3.0+")
      end

      it "parses metadata" do
        expect(skill.metadata).to eq(author: "test-author", version: "1.0")
      end

      it "parses allowed_tools" do
        expect(skill.allowed_tools).to eq(["Bash(git:*)", "Read"])
      end

      it "parses the body" do
        expect(skill.body).to include("# Valid Skill")
        expect(skill.body).to include("## Instructions")
      end

      it "stores the path" do
        expect(skill.path).to eq(fixture_path("valid-skill"))
      end
    end

    context "with missing SKILL.md" do
      it "raises NotFoundError" do
        expect {
          described_class.load(fixture_path("nonexistent"))
        }.to raise_error(AgentSkills::NotFoundError, /SKILL.md not found/)
      end
    end
  end

  describe ".parse" do
    it "parses valid content without path" do
      content = <<~SKILL
        ---
        name: test-skill
        description: A test skill
        ---

        # Test
      SKILL

      skill = described_class.parse(content)

      expect(skill.name).to eq("test-skill")
      expect(skill.description).to eq("A test skill")
      expect(skill.path).to be_nil
    end

    it "raises ParseError for invalid format" do
      expect {
        described_class.parse("no frontmatter here")
      }.to raise_error(AgentSkills::ParseError, /missing YAML frontmatter/)
    end
  end

  describe "#to_prompt_xml" do
    let(:skill) { described_class.load(fixture_path("valid-skill")) }

    it "generates valid XML" do
      xml = skill.to_prompt_xml

      expect(xml).to include('<skill name="valid-skill">')
      expect(xml).to include("<description>")
      expect(xml).to include("<instructions>")
      expect(xml).to include("</skill>")
    end
  end

  describe "#to_h" do
    let(:skill) { described_class.load(fixture_path("valid-skill")) }

    it "returns a hash representation" do
      hash = skill.to_h

      expect(hash[:name]).to eq("valid-skill")
      expect(hash[:description]).to include("valid test skill")
      expect(hash[:license]).to eq("MIT")
    end

    it "excludes nil values" do
      content = <<~SKILL
        ---
        name: minimal
        description: Minimal skill
        ---

        Body
      SKILL

      skill = described_class.parse(content)
      hash = skill.to_h

      expect(hash).not_to have_key(:license)
      expect(hash).not_to have_key(:compatibility)
    end
  end
end
