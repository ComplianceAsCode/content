# AI-Assisted Development Skills

This repository includes a set of skills that automate common
development tasks such as building products, creating rules, mapping
control files, reviewing pull requests, and more. Skills are invoked as
slash commands (e.g., `/build-product rhel9`).

The skills are compatible with any LLM client that supports the
`.claude/skills/` convention, such as
[Claude Code](https://claude.ai/code) and
[Opencode](https://opencode.ai/).

Some skills can optionally use the
[content-mcp](https://github.com/ComplianceAsCode/content-mcp) MCP
(Model Context Protocol) server for structured, deterministic operations
such as rule lookup, control file parsing, and rendered content search.
When the MCP server is not configured, those skills fall back to
filesystem-based alternatives so that every skill completes successfully
either way. The MCP server is not required.

## Finding and Using Skills

Each skill is defined in its own directory under `.claude/skills/`. The
directory name is the skill name (e.g., `.claude/skills/build-product/`
corresponds to `/build-product`). Every skill directory contains a
`SKILL.md` file that fully documents its purpose, usage, arguments,
phases, and behavior.

Skills are self-documenting. Before using a skill, read its `SKILL.md`
to understand what it does, what arguments it expects, and what side
effects it may have.
