---
name: valid-skill
description: A valid test skill for parsing receipts and expenses.
license: MIT
compatibility: Requires Ruby 3.0+
metadata:
  author: test-author
  version: "1.0"
allowed-tools: Bash(git:*) Read
---

# Valid Skill

This is a test skill with all fields populated.

## Instructions

1. Parse the input
2. Extract data
3. Return JSON

## Examples

Input: "Coffee $5"
Output: {"item": "Coffee", "amount": 5}
