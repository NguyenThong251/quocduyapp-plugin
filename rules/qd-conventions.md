# QuocDuyApp Coding Conventions

## Dependency Management

### Never
- ❌ Update multiple libraries at once
- ❌ Skip baseline before updating
- ❌ Ignore major version jumps
- ❌ Commit without verification
- ❌ Big bang rewrite when 2+ major behind

### Always
- ✅ Read `DEPENDENCY-REPORT.md` before updating
- ✅ Create dedicated branch: `update/<package>-<from>-to-<to>`
- ✅ Verify: build → test → bundle size
- ✅ Classify risk first (Critical/Minor/Major)
- ✅ Rollback if any verification fails

## Skill Conventions

### `/qd-outdated`
- Language-agnostic: works on Node.js, PHP, Python, Go, Rust, Java, .NET, Ruby
- Output: `DEPENDENCY-REPORT.md`
- No updates — audit only

### `/qd-update`
- One library at a time
- Pre-requisite: `DEPENDENCY-REPORT.md` from `/qd-outdated`
- Rollback strategy always available

## Git Conventions

### Branch naming
```
update/<package>-<from>-to-<to>
# Example: update/react-19.2.4-to-19.2.5
```

### Commit messages
```
chore(deps): upgrade <package> from <v1> to <v2>

Constraint: <reason>
Confidence: high
Scope-risk: narrow
```

### PR labels
- `dependencies` — normal updates
- `breaking-change` — major version updates
- `security` — CVE updates
