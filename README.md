# quocduyapp-plugin

Dependency management skills for Claude Code.

## Skills

### `/qd-outdated`

Check outdated dependencies across any language and generate a risk-classified report.

```
Supported: Node.js, PHP, Python, Go, Rust, Java, C#, Ruby, React Native
Output: DEPENDENCY-REPORT.md
```

### `/qd-update`

Execute safe, one-by-one dependency updates with baseline and verification.

```
Workflow: Audit → Classify → Baseline → Update ONE → Verify → Deploy
Pre-requisite: Run /qd-outdated first
```

## Install

```bash
/plugin marketplace add https://github.com/NguyenThong251/quocduyapp-plugin
/plugin install quocduyapp@quocduyapp
```

## Quick Start

```bash
# 1. Audit all dependencies
/qd-outdated

# 2. Review DEPENDENCY-REPORT.md

# 3. Update each package one at a time
/qd-update react
/qd-update antd
```

## Supported Languages

| Language | Package Manager |
|----------|----------------|
| Node.js / React | yarn, npm, pnpm |
| PHP | Composer |
| Python | pip, Poetry |
| Go | go |
| Rust | cargo |
| Java | Maven, Gradle |
| C# / .NET | dotnet |
| Ruby | bundler |

## Rules

- One library at a time
- Always create baseline before updating
- Always verify (build + test + bundle size)
- Classify risk: Critical / Minor / Major

## License

MIT
