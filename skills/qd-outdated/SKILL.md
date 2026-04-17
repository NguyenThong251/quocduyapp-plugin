---
name: qd-outdated
description: Check outdated dependencies across any language/project. Generates DEPENDENCY-REPORT.md with risk classification.
triggers:
  - /qd-outdated
  - check outdated dependencies
  - dependency audit
  - library versions
  - which packages need updating
---

# /qd-outdated

You are a dependency audit specialist. Audit all third-party libraries in the project, classify risk, and generate a `DEPENDENCY-REPORT.md`.

## Workflow

### Phase 1: Detect Project Type

Scan the root directory for manifest files:

```bash
ls -la | grep -E "package.json|composer.json|go.mod|Cargo.toml|pom.xml|requirements.txt|pyproject.toml|*.csproj|Gemfile|build.gradle"
```

| Signal Found | Language | PM |
|---|---|---|
| `package.json` | Node.js / React / React Native | yarn / npm / pnpm |
| `composer.json` | PHP | Composer |
| `requirements.txt` / `pyproject.toml` | Python | pip / Poetry |
| `go.mod` | Go | go |
| `Cargo.toml` | Rust | cargo |
| `pom.xml` | Java (Maven) | mvn |
| `build.gradle` | Java (Gradle) | gradle |
| `*.csproj` | C# / .NET | dotnet |
| `Gemfile` | Ruby | bundler |

Stop if no manifest found. Report: "No dependency manifest found in this project."

### Phase 2: Read Dependency Manifest

Read the manifest and extract all dependencies + devDependencies. Use jq if available:

```bash
cat package.json | jq '{dependencies, devDependencies}'
```

If jq unavailable:
```bash
grep -A 50 '"dependencies"' package.json
grep -A 50 '"devDependencies"' package.json
```

Count total packages. Note which are production vs development.

### Phase 3: Identify Package Manager

Check for lockfiles in priority order:

```bash
# Priority: yarn > pnpm > npm > composer > pip > go > cargo > gradle > dotnet
if [ -f "yarn.lock" ]; then PM=yarn
elif [ -f "pnpm-lock.yaml" ]; then PM=pnpm
elif [ -f "package-lock.json" ]; then PM=npm
elif [ -f "composer.lock" ]; then PM=composer
elif [ -f "poetry.lock" ]; then PM=poetry
elif [ -f "go.sum" ]; then PM=go
elif [ -f "Cargo.lock" ]; then PM=cargo
fi
```

### Phase 4: Run Outdated Command

Run the appropriate outdated command for detected PM:

```bash
# Node.js / React / React Native
yarn outdated 2>/dev/null || npm outdated 2>/dev/null || pnpm outdated 2>/dev/null

# PHP
composer outdated --format=json 2>/dev/null || composer outdated 2>/dev/null

# Python
pip list --outdated --format=json 2>/dev/null || poetry show --outdated 2>/dev/null

# Go
go list -m -u all 2>/dev/null

# Rust
cargo outdated 2>/dev/null || echo "cargo-outdated not installed"

# Java (Maven)
mvn versions:display-dependency-updates 2>/dev/null || echo "Maven not available"

# Java (Gradle)
gradle dependencies --configuration runtimeClasspath 2>/dev/null | grep -i update || echo "Gradle not available"

# .NET
dotnet list package --outdated 2>/dev/null || echo "dotnet not available"

# Ruby
bundle outdated 2>/dev/null || echo "bundler not available"
```

Parse the output. Note for each package: current version, wanted version (latest minor), latest version (may be major).

### Phase 5: WebSearch Changelog

For each outdated package, search for:
1. `[package-name] changelog [latest-version]`
2. `[package-name] breaking changes [old-version] [new-version]`
3. `[package-name] CVE security [current-version]`

If WebSearch fails, use npm/npmjs as fallback:
```bash
npm view <package>@latest 2>/dev/null
npm view <package> dist-tags 2>/dev/null
```

Extract: release date, major breaking changes, security fixes.

### Phase 6: Analyze Breaking Changes

Classify each outdated package:

| Level | Trigger | Action |
|---|---|---|
| 🔴 **Critical** | Security CVE detected | Update immediately — no debate |
| 🔴 **Major** | Major version jump (1.x → 2.x) | Separate branch + migration sprint |
| 🟡 **Minor** | Minor version jump (1.2 → 1.3) | Test regression before updating |
| 🟢 **Patch** | Patch version (1.2.3 → 1.2.4) | Safe to update |

Flag: any package 2+ major versions behind = "big bang risk" — recommend incremental.

### Phase 7: Generate Report

Create `DEPENDENCY-REPORT.md` in the project root:

```markdown
# Dependency Outdated Report — [Project Name]

**Generated:** [Date]
**Language:** [Node.js / PHP / Python / Go / Rust / etc.]
**Package Manager:** [Yarn / npm / Composer / pip / etc.]
**Total:** [N] packages | [X] outdated

---

## Summary

| Risk | Count |
|------|-------|
| 🔴 Critical (CVE) | N |
| 🔴 Major (breaking) | N |
| 🟡 Minor (features) | N |
| 🟢 Patch (bug fix) | N |
| ✅ Up-to-date | N |

---

## 🔴 Critical Security Updates

| Package | Current | Latest | CVE | Action |
|---------|---------|--------|-----|--------|
| [name] | [v] | [v] | CVE-XXXX-XXXX | Update immediately |

---

## 🔴 Major Updates (Breaking Changes)

> ⚠️ **Separate branch + migration sprint required**

| Package | Current | Latest | Breaking Changes |
|---------|---------|--------|-----------------|
| [name] | 1.x | 2.x | [brief description] |

---

## 🟡 Minor Updates

| Package | Current | Latest | Changes |
|---------|---------|--------|---------|
| [name] | 1.2 | 1.3 | New features, test regression required |

---

## 🟢 Patch Updates

| Package | Current | Latest |
|---------|---------|--------|
| [name] | 1.2.3 | 1.2.4 |

---

## ✅ Up-to-date

[N] packages already at latest version.

---

## Recommendations

### 🔴 Immediate (P0 — < 24h)
- [ ] Security CVE updates

### 🔴 This Sprint (P1 — 2-4 weeks)
- [ ] Major version updates → separate branch + migration

### 🟡 Next Sprint (P2 — 1-2 weeks)
- [ ] Minor updates → batch, test regression

### 🟢 Later (P3 — quarterly)
- [ ] Patch updates → batch

---

## Preventive Tooling Setup

### Renovate Bot (recommended)
```json
// renovate.json
{
  "extends": ["config:base"],
  "labels": ["dependencies"],
  "packageRules": [
    {
      "matchUpdateTypes": ["major"],
      "labels": ["breaking-change"]
    }
  ]
}
```

### CI: Security Audit
```yaml
# .github/workflows/audit.yml
- name: Security Audit
  run: yarn audit --audit-level=high
  # or: npm audit --audit-level=high
```

### CI: Lockfile Change Detection
```yaml
- name: Check lockfile
  run: git diff --exit-code yarn.lock
```

---

## Next Steps

1. Run `/qd-update <package>` for P0/P1 items
2. Setup Renovate Bot in CI/CD
3. Schedule quarterly `/qd-outdated` audit
```

### Phase 8: Output Summary

Print a console summary table:

```
Dependency Audit Complete — [Project]

Language: [Node.js/PHP/etc.]
Package Manager: [yarn/npm/Composer/etc.]
Total: [N] packages | [X] outdated

🔴 Critical (CVE): N
🔴 Major (breaking): N
🟡 Minor: N
🟢 Patch: N
✅ Up-to-date: N

Report saved: DEPENDENCY-REPORT.md
Next: /qd-update <package-name>
```

## Rules

- **Never update** in this skill — only audit and report
- **Never skip** WebSearch for major version packages
- **Always classify** risk before recommending
- **Multi-project**: If multiple manifests found, audit each separately
- **Partial failure**: If PM command fails, note it and continue with available data

## Fallback (no PM available)

If no package manager CLI is available:
```bash
npm view <package>@latest 2>/dev/null
```
Manually compare with manifest versions.
