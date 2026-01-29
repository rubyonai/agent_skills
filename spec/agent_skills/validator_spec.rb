# frozen_string_literal: true

RSpec.describe AgentSkills::Validator do
  def build_skill(attrs = {})
    defaults = { path: nil, name: "test-skill", description: "A test skill", body: "# Test" }
    AgentSkills::Skill.new(**defaults.merge(attrs))
  end

  describe "#valid?" do
    context "with valid skill" do
      it "returns true" do
        skill = build_skill
        validator = described_class.new(skill)

        expect(validator.valid?).to be true
        expect(validator.errors).to be_empty
      end
    end

    context "name validation" do
      it "requires name" do
        skill = build_skill(name: nil)
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name is required")
      end

      it "requires name to be 64 characters or less" do
        skill = build_skill(name: "a" * 65)
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name must be 64 characters or less")
      end

      it "requires lowercase letters, numbers, and hyphens only" do
        skill = build_skill(name: "Invalid_Name")
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name must contain only lowercase letters, numbers, and hyphens")
      end

      it "rejects names starting with hyphen" do
        skill = build_skill(name: "-invalid")
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name cannot start or end with a hyphen")
      end

      it "rejects names ending with hyphen" do
        skill = build_skill(name: "invalid-")
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name cannot start or end with a hyphen")
      end

      it "rejects consecutive hyphens" do
        skill = build_skill(name: "invalid--name")
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name cannot contain consecutive hyphens")
      end

      it "accepts valid names" do
        valid_names = %w[my-skill skill123 my-skill-v2 a]

        valid_names.each do |name|
          skill = build_skill(name: name)
          validator = described_class.new(skill)

          expect(validator.valid?).to be(true), "Expected '#{name}' to be valid"
        end
      end
    end

    context "description validation" do
      it "requires description" do
        skill = build_skill(description: nil)
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("description is required")
      end

      it "requires description to be 1024 characters or less" do
        skill = build_skill(description: "a" * 1025)
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("description must be 1024 characters or less")
      end
    end

    context "compatibility validation" do
      it "allows empty compatibility" do
        skill = build_skill(compatibility: nil)
        validator = described_class.new(skill)

        expect(validator.valid?).to be true
      end

      it "requires compatibility to be 500 characters or less" do
        skill = build_skill(compatibility: "a" * 501)
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("compatibility must be 500 characters or less")
      end
    end

    context "directory name validation" do
      it "requires name to match directory name when path is present" do
        skill = build_skill(path: "/path/to/wrong-name", name: "my-skill")
        validator = described_class.new(skill)

        expect(validator.valid?).to be false
        expect(validator.errors).to include("name 'my-skill' must match directory name 'wrong-name'")
      end

      it "passes when name matches directory" do
        skill = build_skill(path: "/path/to/my-skill", name: "my-skill")
        validator = described_class.new(skill)

        expect(validator.valid?).to be true
      end

      it "skips directory check when path is nil" do
        skill = build_skill(path: nil, name: "my-skill")
        validator = described_class.new(skill)

        expect(validator.valid?).to be true
      end
    end
  end

  describe ".validate!" do
    it "returns skill when valid" do
      skill = build_skill
      result = described_class.validate!(skill)

      expect(result).to eq(skill)
    end

    it "raises ValidationError when invalid" do
      skill = build_skill(name: nil, description: nil)

      expect {
        described_class.validate!(skill)
      }.to raise_error(AgentSkills::ValidationError, /name is required/)
    end
  end
end
