# frozen_string_literal: true

require "tmpdir"

RSpec.describe AgentSkills::Packager do
  let(:tmpdir) { Dir.mktmpdir }
  let(:skill_path) { File.join(tmpdir, "my-skill") }

  before do
    AgentSkills::Generator.create(
      path: tmpdir,
      name: "my-skill",
      description: "A test skill",
      with_scripts: true
    )

    # Add a script file
    File.write(File.join(skill_path, "scripts", "test.py"), "print('hello')")
  end

  after { FileUtils.rm_rf(tmpdir) }

  describe ".pack" do
    it "creates a .skill file" do
      output = described_class.pack(skill_path, output: File.join(tmpdir, "output.skill"))

      expect(File.exist?(output)).to be true
      expect(output).to end_with(".skill")
    end

    it "uses skill name as default filename" do
      Dir.chdir(tmpdir) do
        output = described_class.pack(skill_path)

        expect(output).to eq("my-skill.skill")
        expect(File.exist?(output)).to be true
      end
    end

    it "includes all skill files in the archive" do
      output = described_class.pack(skill_path, output: File.join(tmpdir, "output.skill"))

      entries = []
      Zip::File.open(output) do |zip|
        zip.each { |entry| entries << entry.name }
      end

      expect(entries).to include("my-skill/SKILL.md")
      expect(entries).to include("my-skill/scripts/test.py")
    end

    it "raises NotFoundError for non-existent path" do
      expect {
        described_class.pack("/nonexistent/path")
      }.to raise_error(AgentSkills::NotFoundError, /not found/)
    end

    it "raises ValidationError for invalid skill" do
      # Create invalid skill (no description)
      invalid_path = File.join(tmpdir, "invalid-skill")
      FileUtils.mkdir_p(invalid_path)
      File.write(File.join(invalid_path, "SKILL.md"), <<~SKILL)
        ---
        name: invalid-skill
        description:
        ---

        Body
      SKILL

      expect {
        described_class.pack(invalid_path)
      }.to raise_error(AgentSkills::ValidationError)
    end
  end

  describe ".unpack" do
    let(:packed_file) { File.join(tmpdir, "packed.skill") }
    let(:extract_dir) { File.join(tmpdir, "extracted") }

    before do
      described_class.pack(skill_path, output: packed_file)
    end

    it "extracts skill to output directory" do
      described_class.unpack(packed_file, output: extract_dir)

      expect(File.exist?(File.join(extract_dir, "my-skill", "SKILL.md"))).to be true
    end

    it "extracts all files" do
      described_class.unpack(packed_file, output: extract_dir)

      expect(File.exist?(File.join(extract_dir, "my-skill", "scripts", "test.py"))).to be true
    end

    it "returns path to extracted skill" do
      result = described_class.unpack(packed_file, output: extract_dir)

      expect(result).to eq(File.join(extract_dir, "my-skill"))
    end

    it "extracted skill can be loaded" do
      extracted_path = described_class.unpack(packed_file, output: extract_dir)

      skill = AgentSkills::Skill.load(extracted_path)

      expect(skill.name).to eq("my-skill")
      expect(skill.description).to eq("A test skill")
    end

    it "raises NotFoundError for non-existent file" do
      expect {
        described_class.unpack("/nonexistent.skill", output: extract_dir)
      }.to raise_error(AgentSkills::NotFoundError, /not found/)
    end
  end
end
