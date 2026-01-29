# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project setup
- Core `Skill` class for parsing SKILL.md files
- `Validator` class for spec compliance checking
- `Generator` class for scaffolding new skills
- `Loader` class for discovering skills from paths
- `Packager` class for creating .skill bundles
- CLI with `new`, `validate`, `list`, `pack`, `unpack`, `info` commands

### Coming Soon
- Rails integration with generators
- Prompt XML rendering
- Semantic skill search

## [0.1.0] - TBD

### Added
- First public release
- Full implementation of Agent Skills specification
- CLI tool (`agent-skills`)
- Ruby API for loading and validating skills

---

[Unreleased]: https://github.com/YOUR_USERNAME/agent_skills/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/YOUR_USERNAME/agent_skills/releases/tag/v0.1.0
