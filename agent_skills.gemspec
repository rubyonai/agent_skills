# frozen_string_literal: true

require_relative "lib/agent_skills/version"

Gem::Specification.new do |spec|
  spec.name          = "agent_skills"
  spec.version       = AgentSkills::VERSION
  spec.authors       = ["rubyonai"]
  spec.email         = ["your-email@example.com"]

  spec.summary       = "Ruby implementation of the Agent Skills open standard"
  spec.description   = <<~DESC
    Parse, validate, create, package, and load Agent Skills in Ruby.
    Agent Skills is an open format (by Anthropic) for giving AI agents
    new capabilities through structured instructions, scripts, and resources.
  DESC
  spec.homepage      = "https://github.com/rubyonai/agent_skills"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rubyonai/agent_skills"
  spec.metadata["changelog_uri"] = "https://github.com/rubyonai/agent_skills/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rubydoc.info/gems/agent_skills"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .circleci appveyor Gemfile])
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rubyzip", "~> 2.3"
  spec.add_dependency "thor", "~> 1.3"
end
