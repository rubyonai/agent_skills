# Agent Skills

[![Gem Version](https://badge.fury.io/rb/agent_skills.svg)](https://badge.fury.io/rb/agent_skills)
[![Ruby](https://github.com/rubyonai/agent_skills/actions/workflows/main.yml/badge.svg)](https://github.com/rubyonai/agent_skills/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**The official Ruby implementation of the [Agent Skills](https://agentskills.io) open standard.**

Agent Skills is an open format (created by Anthropic) for giving AI agents new capabilities and expertise. This gem lets you **parse, validate, create, package, and load** Agent Skills in Ruby applications.

---

## Why Agent Skills?

AI agents are powerful, but they lack **domain-specific knowledge**. Skills solve this by packaging:

- **Instructions** — Step-by-step guidance for specific tasks
- **Scripts** — Executable code the agent can run
- **Resources** — Reference docs, templates, examples

```
Without Skills:                     With Skills:
┌─────────────┐                    ┌─────────────┐
│   Agent     │                    │   Agent     │
│  (generic)  │                    │  + Skills   │
└─────────────┘                    └─────────────┘
      │                                   │
      ▼                                   ▼
"I don't know your                 "I'll follow the expense-parser
 company's expense policy"          skill to extract data correctly"
```

---

## Adoption

Agent Skills is supported by **26+ major AI tools**:

| Tool | Status |
|------|--------|
| Claude Code | ✅ Native support |
| Claude.ai | ✅ Native support |
| GitHub Copilot | ✅ Supported |
| VS Code | ✅ Supported |
| Cursor | ✅ Supported |
| OpenAI Codex | ✅ Supported |
| Gemini CLI | ✅ Supported |
| And 19+ more... | ✅ Growing |

**This gem brings Ruby into the ecosystem.**

---

## Installation

Add to your Gemfile:

```ruby
gem 'agent_skills'
```

Or install directly:

```bash
gem install agent_skills
```

---

## Quick Start

### 1. Create a Skill

```bash
$ agent-skills new expense-parser \
    --description "Extract expense data from receipts into structured JSON"

Created skill at ./expense-parser/
├── SKILL.md
├── scripts/
└── references/
```

### 2. Edit Your Skill

```markdown
<!-- expense-parser/SKILL.md -->
---
name: expense-parser
description: Extract expense data from receipts into structured JSON. Use when user shares receipt images, expense text, or asks to categorize purchases.
---

# Expense Parser

## Output Schema
Return JSON with only these keys:
- `merchant`: Store/vendor name
- `amount`: Numeric value (no currency symbol)
- `date`: YYYY-MM-DD format
- `category`: One of [food, transport, office, utilities, other]

## Guidelines
1. Never guess missing information — omit the field
2. Standardize merchant names ("STARBUCKS #1234" → "Starbucks")
3. Parse amounts as floats, not strings

## Examples

### Input
"Coffee at Starbucks, $5.75, paid yesterday"

### Output
{"merchant": "Starbucks", "amount": 5.75, "category": "food"}
```

### 3. Validate

```bash
$ agent-skills validate expense-parser
✅ Skill 'expense-parser' is valid
```

### 4. Use in Your App

```ruby
require 'agent_skills'

# Load all skills from default paths
loader = AgentSkills::Loader.new
skills = loader.discover

# Get a specific skill
expense_skill = skills['expense-parser']

# Inject into your LLM prompt
system_prompt = <<~PROMPT
  You are a helpful assistant.

  #{expense_skill.to_prompt_xml}
PROMPT
```

---

## What's in a Skill?

A skill is a folder with a `SKILL.md` file:

```
my-skill/
├── SKILL.md          # Required: YAML frontmatter + instructions
├── scripts/          # Optional: Executable Python/Bash/Ruby scripts
├── references/       # Optional: Additional documentation
└── assets/           # Optional: Templates, images, data files
```

### SKILL.md Structure

```markdown
---
name: my-skill                    # Required: lowercase, hyphens only
description: What it does...      # Required: max 1024 chars
license: MIT                      # Optional
compatibility: Requires docker    # Optional: environment needs
metadata:                         # Optional: custom key-values
  author: your-name
  version: "1.0"
---

# Skill Title

Your instructions go here. Write whatever helps the agent
perform the task effectively.

## Sections you might include:
- Step-by-step instructions
- Input/output examples
- Edge cases to handle
- Guidelines and constraints
```

---

## CLI Reference

### `agent-skills new`

Scaffold a new skill:

```bash
agent-skills new my-skill --description "What the skill does"

# Options:
#   -d, --description  Skill description (required)
#   -p, --path         Output directory (default: current)
#   --with-scripts     Include scripts/ directory
#   --with-references  Include references/ directory
```

### `agent-skills validate`

Validate a skill against the specification:

```bash
agent-skills validate ./my-skill

# Checks:
#   ✓ SKILL.md exists
#   ✓ Valid YAML frontmatter
#   ✓ Name follows conventions (lowercase, hyphens)
#   ✓ Name matches directory name
#   ✓ Description within limits
#   ✓ No invalid fields
```

### `agent-skills pack`

Package a skill for distribution:

```bash
agent-skills pack ./my-skill

# Creates: my-skill.skill (zip file)
# Can be shared, uploaded to Claude.ai, or vendored
```

### `agent-skills unpack`

Extract a packaged skill:

```bash
agent-skills unpack my-skill.skill --output ./skills/
```

### `agent-skills list`

List all discovered skills:

```bash
agent-skills list

# Output:
# expense-parser      Extract expense data from receipts...
# code-reviewer       Review code for best practices...
# doc-generator       Generate documentation from code...
```

### `agent-skills info`

Show detailed skill information:

```bash
agent-skills info expense-parser

# Output:
# Name:        expense-parser
# Description: Extract expense data from receipts...
# Path:        ~/.config/claude/skills/expense-parser
# Scripts:     validate.py, categorize.rb
# References:  categories.md, examples.md
```

---

## Ruby API

### Loading Skills

```ruby
require 'agent_skills'

# Default paths: ~/.config/claude/skills, .claude/skills, ./skills
loader = AgentSkills::Loader.new
skills = loader.discover

# Custom paths
loader = AgentSkills::Loader.new(
  paths: [
    '/path/to/company/skills',
    Rails.root.join('app/skills')
  ]
)

# Access skills
skill = skills['expense-parser']
skill.name          # => "expense-parser"
skill.description   # => "Extract expense data..."
skill.body          # => Full markdown instructions
skill.scripts       # => ["scripts/validate.py"]
skill.references    # => ["references/categories.md"]
```

### Parsing a Single Skill

```ruby
skill = AgentSkills::Skill.load('./my-skill')

skill.name          # => "my-skill"
skill.description   # => "..."
skill.license       # => "MIT" or nil
skill.compatibility # => "Requires docker" or nil
skill.metadata      # => { "author" => "...", "version" => "1.0" }
skill.body          # => Markdown content after frontmatter
```

### Validation

```ruby
skill = AgentSkills::Skill.load('./my-skill')
validator = AgentSkills::Validator.new(skill)

if validator.valid?
  puts "Skill is valid!"
else
  validator.errors.each do |error|
    puts "Error: #{error}"
  end
end

# Or validate and raise on error
AgentSkills::Validator.validate!(skill)  # Raises ValidationError if invalid
```

### Generating Prompt XML

```ruby
skill = AgentSkills::Skill.load('./expense-parser')

# Generate XML for injection into system prompt
xml = skill.to_prompt_xml

# Output:
# <skill name="expense-parser">
#   <description>Extract expense data from receipts...</description>
#   <instructions>
#     # Expense Parser
#     ## Output Schema
#     ...
#   </instructions>
# </skill>
```

### Creating Skills Programmatically

```ruby
AgentSkills::Generator.create(
  path: './skills',
  name: 'my-skill',
  description: 'What this skill does',
  with_scripts: true,
  with_references: true
)
```

### Packaging Skills

```ruby
# Pack a skill into .skill file
output_path = AgentSkills::Packager.pack('./my-skill')
# => "my-skill.skill"

# Pack with custom output path
AgentSkills::Packager.pack('./my-skill', output: '/tmp/my-skill.skill')

# Unpack a .skill file
AgentSkills::Packager.unpack('my-skill.skill', output: './extracted/')
```

### Finding Relevant Skills

```ruby
loader = AgentSkills::Loader.new.discover

# Simple keyword matching
relevant = loader.find_relevant("parse this receipt")
# => [#<AgentSkills::Skill name="expense-parser">, ...]

# Get skill instructions for prompt
context = relevant.map(&:to_prompt_xml).join("\n")
```

---

## Rails Integration

### Setup

```ruby
# config/initializers/agent_skills.rb
require 'agent_skills'

AGENT_SKILLS = AgentSkills::Loader.new(
  paths: [
    Rails.root.join('app/skills'),      # App-specific skills
    Rails.root.join('vendor/skills'),   # Third-party skills
  ]
).discover

Rails.logger.info "Loaded #{AGENT_SKILLS.count} agent skills"
```

### Using in Services

```ruby
# app/services/ai_assistant.rb
class AIAssistant
  def initialize(client:)
    @client = client  # Anthropic or OpenAI client
  end

  def chat(message, skill_names: [])
    skills_xml = skill_names
      .map { |name| AGENT_SKILLS[name]&.to_prompt_xml }
      .compact
      .join("\n")

    system = <<~PROMPT
      You are a helpful assistant.

      You have access to these skills:
      #{skills_xml}

      Use skills when relevant to the user's request.
    PROMPT

    @client.messages.create(
      model: "claude-sonnet-4-20250514",
      system: system,
      messages: [{ role: "user", content: message }]
    )
  end
end

# Usage
assistant = AIAssistant.new(client: Anthropic::Client.new)
assistant.chat("Parse this receipt: Coffee $4.50", skill_names: ['expense-parser'])
```

### Generator (Coming Soon)

```bash
rails generate skill expense_parser --description "Parse expense receipts"

# Creates:
#   app/skills/expense-parser/SKILL.md
#   app/skills/expense-parser/scripts/.keep
#   app/skills/expense-parser/references/.keep
```

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/validate-skills.yml
name: Validate Skills

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'

      - name: Install agent_skills
        run: gem install agent_skills

      - name: Validate all skills
        run: |
          for skill in skills/*/; do
            echo "Validating $skill..."
            agent-skills validate "$skill"
          done
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

for skill in skills/*/; do
  if ! agent-skills validate "$skill" > /dev/null 2>&1; then
    echo "❌ Invalid skill: $skill"
    agent-skills validate "$skill"
    exit 1
  fi
done

echo "✅ All skills valid"
```

---

## Comparison with Other Implementations

| Feature | agent_skills (Ruby) | skills-ref (Python) | openskills (Node) |
|---------|---------------------|---------------------|-------------------|
| Parse SKILL.md | ✅ | ✅ | ✅ |
| Validate | ✅ | ✅ | ✅ |
| Generate/Scaffold | ✅ | ❌ | ✅ |
| Package (.skill) | ✅ | ✅ | ✅ |
| CLI | ✅ | ✅ | ✅ |
| Rails Integration | ✅ | N/A | N/A |
| Prompt XML | ✅ | ✅ | ✅ |

---

## Specification Compliance

This gem implements the [Agent Skills Specification](https://agentskills.io/specification):

- ✅ SKILL.md parsing with YAML frontmatter
- ✅ Required fields: `name`, `description`
- ✅ Optional fields: `license`, `compatibility`, `metadata`, `allowed-tools`
- ✅ Name validation (lowercase, hyphens, max 64 chars)
- ✅ Description validation (max 1024 chars)
- ✅ Directory structure conventions
- ✅ Progressive disclosure support
- ✅ .skill packaging format

---

## Roadmap

### v0.1.0 (Current)
- [x] Core SKILL.md parsing
- [x] Validation against spec
- [x] CLI: new, validate, list
- [x] Basic skill loading

### v0.2.0
- [ ] Packaging (.skill files)
- [ ] CLI: pack, unpack, info
- [ ] Prompt XML generation
- [ ] Find relevant skills by query

### v0.3.0
- [ ] Rails generators
- [ ] Railtie integration
- [ ] ActiveSupport notifications

### v0.4.0
- [ ] Skill registry/marketplace integration
- [ ] Semantic search for skill matching
- [ ] Langchain.rb integration

### v1.0.0
- [ ] Stable API
- [ ] Full spec compliance
- [ ] Production-ready

---

## Contributing

We welcome contributions! This gem aims to be the official Ruby implementation of Agent Skills.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure all tests pass (`bundle exec rspec`)
5. Ensure code style passes (`bundle exec rubocop`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/agent_skills.git
cd agent_skills
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check style
```

---

## Related Resources

- [Agent Skills Specification](https://agentskills.io) — The official open standard
- [Anthropic Skills Repository](https://github.com/anthropics/skills) — Example skills
- [agentskills/agentskills](https://github.com/agentskills/agentskills) — Spec and reference SDK
- [Claude Code Documentation](https://docs.anthropic.com) — Using skills with Claude

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

---

## Acknowledgments

- [Anthropic](https://anthropic.com) for creating and open-sourcing the Agent Skills standard
- The Ruby community for continuous inspiration
- All [contributors](https://github.com/YOUR_USERNAME/agent_skills/graphs/contributors) who help improve this gem

---

<p align="center">
  <b>Built with ❤️ for the Ruby community</b>
  <br>
  <a href="https://agentskills.io">agentskills.io</a> •
  <a href="https://github.com/rubyonai/agent_skills">GitHub</a> •
  <a href="https://rubygems.org/gems/agent_skills">RubyGems</a>
</p>
