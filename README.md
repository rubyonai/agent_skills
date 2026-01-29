# Agent Skills

[![Gem Version](https://badge.fury.io/rb/agent_skills.svg)](https://badge.fury.io/rb/agent_skills)
[![CI](https://github.com/rubyonai/agent_skills/actions/workflows/ci.yml/badge.svg)](https://github.com/rubyonai/agent_skills/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Ruby implementation of the [Agent Skills](https://agentskills.io) open standard for giving AI agents new capabilities.

## What are Agent Skills?

Skills are folders containing instructions, scripts, and resources that AI agents can load to perform specialized tasks. The format is supported by Claude, GitHub Copilot, Cursor, VS Code, and [26+ other tools](https://agentskills.io).

```
my-skill/
├── SKILL.md       # Instructions (required)
├── scripts/       # Executable code (optional)
└── references/    # Additional docs (optional)
```

## Installation

```ruby
gem 'agent_skills'
```

Or install directly:

```bash
gem install agent_skills
```

## Usage

### CLI

```bash
# Create a new skill
agent-skills new expense-parser -d "Extract expense data from receipts"

# Validate a skill
agent-skills validate ./expense-parser

# List discovered skills
agent-skills list

# Package for distribution
agent-skills pack ./expense-parser
```

### Ruby

```ruby
require 'agent_skills'

# Load a skill
skill = AgentSkills::Skill.load('./my-skill')
skill.name          # => "my-skill"
skill.description   # => "What it does..."
skill.body          # => Markdown instructions

# Validate
validator = AgentSkills::Validator.new(skill)
validator.valid?    # => true/false
validator.errors    # => ["name is required", ...]

# Discover all skills
loader = AgentSkills::Loader.new
skills = loader.discover
skills['expense-parser'].to_prompt_xml

# Generate prompt XML for LLM
skill.to_prompt_xml
# => <skill name="..."><description>...</description>...</skill>
```

### Rails

```ruby
# config/initializers/agent_skills.rb
SKILLS = AgentSkills::Loader.new(
  paths: [Rails.root.join('app/skills')]
).discover

# In your service
skill = SKILLS['expense-parser']
system_prompt = "You have this skill:\n#{skill.to_prompt_xml}"
```

## SKILL.md Format

```markdown
---
name: my-skill
description: What this skill does and when to use it.
---

# My Skill

Your instructions here...
```

See the [full specification](https://agentskills.io/specification) for all options.

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
- [API Documentation](https://rubydoc.info/gems/agent_skills)
