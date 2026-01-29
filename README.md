# Agent Skills

[![Gem Version](https://badge.fury.io/rb/agent_skills.svg)](https://rubygems.org/gems/agent_skills)
[![CI](https://github.com/rubyonai/agent_skills/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/rubyonai/agent_skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby](https://img.shields.io/badge/Ruby-3.0%2B-red.svg)](https://www.ruby-lang.org)

Ruby implementation of the [Agent Skills](https://agentskills.io) open standard — a simple format for giving AI agents new capabilities.

## What are Agent Skills?

Agent Skills are portable folders of instructions that AI agents can load to perform specialized tasks. The format is supported by **Claude, GitHub Copilot, Cursor, VS Code**, and [26+ other tools](https://agentskills.io).

```
my-skill/
├── SKILL.md          # Instructions for the agent (required)
├── scripts/          # Executable code (optional)
├── references/       # Supporting docs (optional)
└── assets/           # Templates, data files (optional)
```

## Installation

Add to your Gemfile:

```ruby
gem 'agent_skills'
```

Or install directly:

```bash
gem install agent_skills
```

## Quick Start

```bash
# Create a new skill
agent-skills new my-skill -d "Description of what this skill does"

# Validate against spec
agent-skills validate ./my-skill

# Package for distribution
agent-skills pack ./my-skill
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `new NAME -d DESC` | Create a new skill |
| `validate PATH` | Validate skill against spec |
| `list` | List discovered skills |
| `info PATH` | Show skill details |
| `pack PATH` | Package into .skill file |
| `unpack FILE` | Extract a .skill file |

## Ruby API

```ruby
require 'agent_skills'

# Load and parse a skill
skill = AgentSkills::Skill.load('./my-skill')
skill.name          # => "my-skill"
skill.description   # => "What it does..."

# Validate against spec
validator = AgentSkills::Validator.new(skill)
validator.valid?    # => true
validator.errors    # => []

# Discover skills from paths
loader = AgentSkills::Loader.new(paths: ['./skills'])
loader.discover
loader['my-skill']  # => #<AgentSkills::Skill>

# Generate prompt XML for LLM injection
skill.to_prompt_xml
# => "<skill name=\"my-skill\"><description>...</description>...</skill>"

# Create a new skill programmatically
AgentSkills::Generator.create(
  path: './skills',
  name: 'my-skill',
  description: 'What this skill does'
)

# Package and distribute
AgentSkills::Packager.pack('./my-skill')
AgentSkills::Packager.unpack('my-skill.skill', output: './extracted')
```

## SKILL.md Format

```markdown
---
name: my-skill
description: What this skill does and when to use it.
license: MIT                        # optional
compatibility: Requires Python 3.x  # optional
---

# My Skill

Instructions for the agent go here...
```

See the [full specification](https://agentskills.io/specification) for details.

## Development

```bash
git clone https://github.com/rubyonai/agent_skills.git
cd agent_skills
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/rubyonai/agent_skills).

## License

MIT License. See [LICENSE](LICENSE) for details.

## Resources

- [Agent Skills Specification](https://agentskills.io)
- [Example Skills](https://github.com/anthropics/skills)
- [RubyGems](https://rubygems.org/gems/agent_skills)
