# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-29

### Added

- `Skill` class for parsing SKILL.md files with YAML frontmatter
- `Validator` class for validating skills against agentskills.io specification
- `Generator` class for scaffolding new skills
- `Loader` class for discovering skills from filesystem paths
- `Packager` class for creating and extracting .skill bundles
- CLI tool with commands: `new`, `validate`, `list`, `info`, `pack`, `unpack`, `version`
- Support for `scripts/`, `references/`, and `assets/` directories
- `to_prompt_xml` method for LLM prompt injection
- GitHub Actions CI workflow

---

[Unreleased]: https://github.com/rubyonai/agent_skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/rubyonai/agent_skills/releases/tag/v0.1.0
