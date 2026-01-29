# frozen_string_literal: true

require "zip"
require "fileutils"

module AgentSkills
  class Packager
    SKILL_EXTENSION = ".skill"

    def self.pack(skill_path, output: nil)
      new(skill_path).pack(output: output)
    end

    def self.unpack(skill_file, output:)
      new(nil).unpack(skill_file, output: output)
    end

    def initialize(skill_path)
      @skill_path = skill_path
    end

    def pack(output: nil)
      validate_skill!

      skill = Skill.load(@skill_path)
      Validator.validate!(skill)

      output_file = output || "#{skill.name}#{SKILL_EXTENSION}"

      create_zip(output_file)
      output_file
    end

    def unpack(skill_file, output:)
      raise NotFoundError, "Skill file not found: #{skill_file}" unless File.exist?(skill_file)

      FileUtils.mkdir_p(output)

      Zip::File.open(skill_file) do |zip|
        zip.each do |entry|
          dest = File.join(output, entry.name)
          FileUtils.mkdir_p(File.dirname(dest))
          entry.extract(dest) { true } # overwrite existing
        end
      end

      # Return the extracted skill directory
      skill_dirs = Dir.glob(File.join(output, "*", "SKILL.md")).map { |f| File.dirname(f) }
      skill_dirs.first || output
    end

    private

    def validate_skill!
      raise NotFoundError, "Skill path not found: #{@skill_path}" unless File.directory?(@skill_path)

      skill_md = File.join(@skill_path, "SKILL.md")
      raise NotFoundError, "SKILL.md not found in #{@skill_path}" unless File.exist?(skill_md)
    end

    def create_zip(output_file)
      File.delete(output_file) if File.exist?(output_file)

      Zip::File.open(output_file, Zip::File::CREATE) do |zip|
        add_directory_to_zip(zip, @skill_path, File.basename(@skill_path))
      end
    end

    def add_directory_to_zip(zip, dir_path, base_name)
      Dir.glob(File.join(dir_path, "**", "*")).each do |file|
        next if File.directory?(file)

        relative_path = file.sub("#{dir_path}/", "")
        zip_path = File.join(base_name, relative_path)
        zip.add(zip_path, file)
      end
    end
  end
end
