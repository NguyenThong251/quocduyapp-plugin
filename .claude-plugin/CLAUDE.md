# QuocDuyApp — Dependency Management Skills

This plugin provides two skills for managing dependencies across any language.

## Available Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `/qd-outdated` | "check outdated", "dependency audit" | Audit all deps, generate DEPENDENCY-REPORT.md |
| `/qd-update` | "update [package]", "upgrade [package]" | Safe one-by-one update with baseline + verify |

## Supported Languages

Node.js, PHP, Python, Go, Rust, Java, C#, Ruby, React Native

## Key Rules

- One library at a time
- Always create baseline before updating
- Always verify (build + test + bundle size)
- Classify risk: Critical / Minor / Major
