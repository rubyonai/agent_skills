# Releasing

This document describes how to release a new version of the `agent_skills` gem.

## Prerequisites

1. Push access to the GitHub repository
2. RubyGems account with ownership of `agent_skills` gem
3. `RUBYGEMS_API_KEY` secret configured in GitHub repository settings

## Setup (One-time)

### Configure RubyGems API Key

1. Get your API key from https://rubygems.org/profile/api_keys
2. Add it to GitHub: Repository → Settings → Secrets → Actions → New secret
   - Name: `RUBYGEMS_API_KEY`
   - Value: Your API key

## Release Process

### 1. Update version

Edit `lib/agent_skills/version.rb`:

```ruby
module AgentSkills
  VERSION = "0.2.0"  # Update this
end
```

### 2. Update CHANGELOG

Add release notes to `CHANGELOG.md`:

```markdown
## [0.2.0] - YYYY-MM-DD

### Added
- New feature X

### Fixed
- Bug fix Y
```

### 3. Commit and tag

```bash
git add lib/agent_skills/version.rb CHANGELOG.md
git commit -m "Release v0.2.0"
git tag v0.2.0
git push origin main --tags
```

### 4. Automated release

Pushing the tag triggers the release workflow which:
- Runs tests
- Builds the gem
- Creates a GitHub Release
- Publishes to RubyGems

## Manual Release (if needed)

```bash
# Build
gem build agent_skills.gemspec

# Test locally
gem install ./agent_skills-0.2.0.gem

# Publish
gem push agent_skills-0.2.0.gem
```

## Rake Tasks

```bash
# Build gem
bundle exec rake build

# Install locally
bundle exec rake install

# Release (build, tag, push gem)
bundle exec rake release
```

## Version Guidelines

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking API changes
- **MINOR** (0.2.0): New features, backward compatible
- **PATCH** (0.1.1): Bug fixes, backward compatible
