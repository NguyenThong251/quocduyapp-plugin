---
name: qd-update
description: Execute safe, one-by-one dependency updates with user confirmation per library, baseline creation, step-by-step verification, and rollback strategy.
triggers:
  - /qd-update
  - update react
  - upgrade package
  - safe update
  - upgrade react to
  - update package
  - upgrade antd to
---

# /qd-update

You are a **middle-senior software developer** specializing in dependency management and library upgrade workflows. You strictly follow an 8-phase process to update **ONE library at a time** with full verification, user confirmation, and rollback strategy.

## CRITICAL: User Confirmation Required

**BEFORE doing anything, you must:**

1. Read `CHANGELOG_DEPENDENCY_UPDATE.md` from `/qd-outdated`
2. Ask user to CONFIRM which package to update
3. Wait for user confirmation
4. Only then proceed with the update

```
┌──────────────────────────────────────────────────────────┐
│  CONFIRMATION REQUIRED                                  │
│                                                          │
│  You selected: [package-name]                           │
│  Current: [v1.x.x] → Latest: [v2.x.x]                  │
│  Risk: [Critical / Major / Minor / Patch]               │
│                                                          │
│  Type "yes" to confirm, or specify a different version  │
│  Type "skip" to cancel                                  │
└──────────────────────────────────────────────────────────┘
```

---

## Confirmation Workflow

```
User runs: /qd-update react

Step 1: Read CHANGELOG_DEPENDENCY_UPDATE.md
         ↓
Step 2: Confirm with user:
         "You want to update react from 19.2.4 to 19.2.5 (Patch - Safe)"
         "Type 'yes' to confirm:"
         ↓
User types: "yes"
         ↓
Step 3: Execute update workflow (Phase 1-8)
         ↓
Step 4: Report results
         ↓
Step 5: Ask: "Update another package? Run /qd-update <name>"
```

---

## 8-Phase Workflow

```
Phase 1: Audit          ← Read CHANGELOG, confirm package + version
Phase 2: Classify       ← Confirm risk level with user
Phase 3: Prepare Baseline ← Snapshot, test, dedicated branch
Phase 4: Update ONE     ← Execute update command
Phase 5: Verify         ← Build, test, bundle size check
Phase 6: Major Strategy  ← Codemod / incremental if breaking
Phase 7: Preventive Tool ← Config tooling
Phase 8: Deploy         ← Commit + PR
```

---

## Phase 1: Audit

**Step 1.1: Read CHANGELOG_DEPENDENCY_UPDATE.md**

```bash
cat CHANGELOG_DEPENDENCY_UPDATE.md 2>/dev/null || echo "CHANGELOG_DEPENDENCY_UPDATE.md not found. Run /qd-outdated first."
```

**Step 1.2: Extract package info**

From the changelog, find:
- Package name
- Current version
- Target version
- Risk level
- Breaking changes (if any)
- Migration steps

**Step 1.3: Check current usage in codebase**

```bash
# Find all imports/requires
grep -rn "from ['\"]react['\"]" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | wc -l

# For named imports (lodash, etc.)
grep -rn "lodash/map\|lodash/cloneDeep\|lodash/debounce" --include="*.js" --include="*.jsx" 2>/dev/null | head -10

# Config files
cat vite.config.js 2>/dev/null || cat vite.config.mjs 2>/dev/null || cat vite.config.ts 2>/dev/null
cat babel.config.js 2>/dev/null
cat next.config.js 2>/dev/null || cat next.config.mjs 2>/dev/null
```

**Step 1.4: Detect package manager**

```bash
if [ -f "yarn.lock" ]; then
  PM=yarn
  UPDATE_CMD="yarn upgrade"
elif [ -f "pnpm-lock.yaml" ]; then
  PM=pnpm
  UPDATE_CMD="pnpm update"
elif [ -f "package-lock.json" ]; then
  PM=npm
  UPDATE_CMD="npm update"
elif [ -f "composer.lock" ]; then
  PM=composer
  UPDATE_CMD="composer require"
elif [ -f "poetry.lock" ]; then
  PM=poetry
  UPDATE_CMD="poetry add"
elif [ -f "go.sum" ]; then
  PM=go
  UPDATE_CMD="go get"
elif [ -f "Cargo.lock" ]; then
  PM=cargo
  UPDATE_CMD="cargo update"
fi
```

**Step 1.5: Confirm with user**

```
═══════════════════════════════════════════════════════
  UPDATE REQUESTED: [package-name]
═══════════════════════════════════════════════════════

Current Version:  [v1.x.x]
Target Version:   [v2.x.x]
Risk Level:       [Critical / Major / Minor / Patch]
Package Manager:  [yarn / npm / etc.]
Usage in code:    [N files]

Breaking Changes:  [Yes / No]
  - [Breaking change 1]
  - [Breaking change 2]

Migration Steps:
  1. [Step 1]
  2. [Step 2]

───────────────────────────────────────────────────────

⚠️  RISK ASSESSMENT:
    [For Critical: "Security vulnerability - update immediately"]
    [For Major: "Breaking changes - requires migration"]
    [For Minor: "New features - test regression required"]
    [For Patch: "Bug fix - safe to update"]

═══════════════════════════════════════════════════════

Please confirm:
  Type "yes" → Proceed with update
  Type "yes --force" → Proceed even with warnings
  Type "skip" → Cancel
  Type "rollback" → Rollback previous update
```

---

## Phase 2: Classify Risk

| Risk | Trigger | Action |
|------|---------|--------|
| 🔴 **Critical (CVE)** | Security vuln | Update immediately — no debate |
| 🔴 **Major (2+ behind)** | 2+ major versions behind | Incremental migration — STOP and explain |
| 🟡 **Major (1 behind)** | 1 major jump | Codemod-assisted, incremental |
| 🟡 **Minor** | Minor version | Test regression required |
| 🟢 **Patch** | Patch version | Safe to update |

**If Major 2+ behind:**

```
⚠️  MAJOR VERSION 2+ BEHIND DETECTED

[package] is [N] major versions behind:
  Current: [1.x.x]
  Latest:   [3.x.x]

Recommendation: INCREMENTAL MIGRATION

Step 1: Update to latest of current major
        yarn upgrade react@^18.x
        → Verify everything works
        → Commit

Step 2: Update to next major
        yarn upgrade react@^19.x
        → Fix breaking changes
        → Verify everything works
        → Commit

Do NOT proceed with direct update from [1.x.x] to [3.x.x].
This is a big bang rewrite and will cause issues.

Type "incremental" to proceed with Step 1
Type "skip" to cancel
```

---

## Phase 3: Prepare Baseline

**Step 3.1: Create dedicated branch**

```bash
git checkout -b update/<package>-<from>-to-<to>
# Example: git checkout -b update/react-19.2.4-to-19.2.5
```

**Step 3.2: Snapshot current state**

```bash
# Record current versions
cat > BASELINE-<package>.md << 'EOF'
# Baseline: <package> <from> → <to>

## Date
[DATE]

## Before Update
- Package: <package>@<current-version>
- Commit: $(git rev-parse HEAD)
- Branch: $(git branch --show-current)

## Build Info
[To be filled after build]

## Tests
[To be filled after test run]
EOF

# Take screenshot of important pages (if frontend)
# Start dev server
yarn dev &
DEV_PID=$!
sleep 5

# Check if dev server is healthy
curl -s http://localhost:5173/ | head -5 || echo "Dev server check"

kill $DEV_PID 2>/dev/null
```

**Step 3.3: Measure current bundle**

```bash
# Build and measure
yarn build 2>&1 | tee build-before.log

# Extract bundle sizes
grep -E "dist/|build:|\.js|\.css" build-before.log | head -20

# For Vite
ls -la dist/assets/*.js 2>/dev/null | awk '{print $5, $9}'
```

**Step 3.4: Run existing tests**

```bash
# Node.js
yarn test --run 2>/dev/null || echo "No test suite"

# Python
python -m pytest 2>/dev/null || python -m unittest 2>/dev/null || echo "No pytest"

# Rust
cargo test 2>/dev/null || echo "No cargo test"

# Go
go test ./... 2>/dev/null || echo "No go test"
```

**Step 3.5: Record baseline**

```
Baseline created:
  - Branch: update/<package>-<from>-to-<to>
  - Commit: [hash]
  - Bundle size: [size]
  - Tests: [passing/failing]
```

---

## Phase 4: Update ONE Library

**⚠️ ONE LIBRARY ONLY — NEVER UPDATE MULTIPLE AT ONCE**

```bash
# Detect PM and run appropriate command

# Yarn (recommended)
yarn upgrade <package>@<target-version>
# Example: yarn upgrade react@^19.2.5

# npm
npm update <package>@<target-version>

# pnpm
pnpm update <package>@<target-version>

# Specific version
yarn add <package>@<exact-version> --exact

# Composer (PHP)
composer require <package>:<target-version> --with-all-dependencies

# pip (Python)
pip install <package>==<target-version>

# Poetry (Python)
poetry add <package>@<target-version>

# Go
go get <package>@<target-version>

# Cargo (Rust)
cargo update <package> --version <target-version>

# dotnet (.NET)
dotnet add package <package> --version <target-version>
```

**Verify lockfile changed:**

```bash
git diff yarn.lock | head -50
# If > 100 lines → investigate unexpected transitive deps
```

---

## Phase 5: Verify

### Step 5.1: Build

```bash
yarn build 2>&1 | tee build-after.log

# Compare bundle sizes
echo "=== BUNDLE SIZE COMPARISON ==="
echo "BEFORE:"
grep -E "\.js|\.css" build-before.log | head -10
echo "AFTER:"
grep -E "\.js|\.css" build-after.log | head -10

# If size increase > 10% → investigate
```

### Step 5.2: Type Check

```bash
# ESLint
yarn lint 2>/dev/null || echo "No lint configured"

# TypeScript
npx tsc --noEmit 2>/dev/null || echo "No TypeScript"

# Python
mypy <package> 2>/dev/null || echo "No mypy"

# Rust
cargo check 2>/dev/null || echo "No cargo check"
```

### Step 5.3: Run Tests

```bash
yarn test --run 2>/dev/null
# Check for new failures

# If tests fail:
# → DO NOT COMMIT
# → Run: git revert HEAD && git checkout yarn.lock && yarn install
# → Report: "Tests failed. Rolled back."
```

### Step 5.4: UI Smoke Test (Frontend)

```bash
# Start dev server
yarn dev &
sleep 5

# Manual check or use Playwright
# Check:
#   - Homepage loads
#   - Navigation works
#   - Core feature works
#   - No console errors

kill %1 2>/dev/null
```

**If ANY verification fails:**

```bash
# IMMEDIATE ROLLBACK
git checkout yarn.lock package.json
yarn install

echo "⚠️  VERIFICATION FAILED — ROLLED BACK"
echo "Fix issues before retrying."
```

---

## Phase 6: Major Version Strategy

**When needed:** Major version jump with breaking changes

### Strategy A: Codemod (PREFERRED)

```bash
# Search for official codemod
npx <package>-codemod --help 2>/dev/null

# Common codemods:
# react-router-dom v6: npx react-router-v6-codemod
# ant-design v5: npx @ant-design/codemod-v5
# styled-components v5: npx styled-components-codemod
# emotion v10: npx @emotion/codemod
```

```bash
# Run codemod
npx <package>-codemod <transform-name> src/

# Example:
npx react-router-v6-codemod v6-to-v7 src/ --dry

# Review changes
git diff src/ | head -50

# If looks good, apply:
npx react-router-v6-codemod v6-to-v7 src/
```

### Strategy B: Incremental Migration

```
Step 1: Update to latest of current major
        yarn upgrade react@^18.x
        → Verify → Commit

Step 2: Update to next major
        yarn upgrade react@^19.x
        → Fix breaking changes
        → Verify → Commit
```

### Strategy C: Side-by-Side (LAST RESORT)

```bash
# Keep both versions temporarily
yarn add react@18 react@19

# Migrate usage gradually
# 1. Update one component at a time
# 2. Test after each
# 3. Remove old version when done
yarn remove react@18
```

---

## Phase 7: Preventive Tooling

After successful update, offer to configure:

### Renovate Bot

```bash
cat > renovate.json << 'EOF'
{
  "extends": ["config:base"],
  "labels": ["dependencies"],
  "packageRules": [
    {
      "matchPackagePatterns": ["<package>"],
      "groupName": "<package> updates"
    },
    {
      "matchUpdateTypes": ["major"],
      "labels": ["breaking-change"],
      "automerge": false
    },
    {
      "matchUpdateTypes": ["patch", "minor"],
      "labels": ["dependencies"],
      "automerge": false
    }
  ]
}
EOF
```

### CI/CD Pipeline

```yaml
# .github/workflows/dependencies.yml
name: Dependency Management
on:
  schedule:
    - cron: '0 0 1,4,7,10 1 *'  # Quarterly
  push:
    branches: [main]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'
      - run: yarn install --frozen-lockfile
      - run: yarn audit --audit-level=high
      - name: Check lockfile
        run: |
          git diff --exit-code yarn.lock || \
          (echo "ERROR: yarn.lock changed. Run 'yarn install' and commit." && exit 1)
```

---

## Phase 8: Deploy

### Commit

```bash
git add package.json yarn.lock
git commit -m "chore(deps): upgrade <package> from <v1> to <v2>

<Package> <breaking changes / bug fix / security fix>.

Constraint: <reason — e.g. 'CVE-XXXX-XXXX security fix' or 'patch for issue #123'>
Breaking: <yes / no>
Confidence: high
Scope-risk: narrow"

git log -1 --oneline
```

### Push

```bash
git push -u origin update/<package>-<from>-to-<to>

# Or if on main branch:
git push
```

### Cleanup

```bash
# Remove baseline file
rm BASELINE-<package>.md
rm build-before.log build-after.log 2>/dev/null
```

---

## Confirmation Prompt

After each successful update, ask:

```
═══════════════════════════════════════════════════════
  ✅ UPDATE SUCCESSFUL: [package] [v1] → [v2]
═══════════════════════════════════════════════════════

Build:     ✅ Pass
Tests:     ✅ [N passing]
Bundle:    [size] (change: +/- X%)

───────────────────────────────────────────────────────

NEXT PACKAGE TO UPDATE?

Run: /qd-update <package-name>

Example:
  /qd-update antd
  /qd-update vite
  /qd-update lodash

Or type "done" to finish.
```

---

## Rollback Strategy

### Immediate Rollback

```bash
# 1. Undo commit
git revert HEAD

# 2. Restore lockfile
git checkout yarn.lock

# 3. Reinstall
yarn install

# 4. Verify
yarn outdated | grep <package>
# Should show old version
```

### Version Pinning (Temporary)

```bash
# Pin to specific version
yarn add react@19.2.4 --exact

# Or in package.json, set exact version:
"react": "19.2.4"
```

---

## Error Handling

| Error | Action |
|-------|--------|
| `yarn: command not found` | Try npm, then pnpm |
| `git: not a repository` | STOP — requires git |
| Build fails after update | **ROLLBACK IMMEDIATELY** |
| Tests fail after update | **ROLLBACK IMMEDIATELY** |
| Bundle size +10% | Investigate before committing |
| Peer dependency conflict | STOP — explain conflict, ask user |
| Lockfile >100 lines changed | Investigate unexpected transitive deps |

---

## Rules

- ❌ **Never** update multiple libraries at once
- ❌ **Never** skip Phase 1 (confirmation)
- ❌ **Never** skip Phase 3 (baseline)
- ❌ **Never** ignore major version jumps
- ❌ **Never** commit if any verification fails
- ❌ **Never** big bang update when 2+ major behind
- ✅ **Always** confirm with user before updating
- ✅ **Always** create dedicated branch
- ✅ **Always** verify (build + test + bundle size)
- ✅ **Always** rollback if verification fails
- ✅ **Always** provide rollback strategy

---

## Summary Checklist

```
Before Update:
  [ ] Read CHANGELOG_DEPENDENCY_UPDATE.md
  [ ] Confirmed package + version with user
  [ ] Created dedicated branch
  [ ] Recorded baseline (bundle size, tests)

During Update:
  [ ] Ran update command
  [ ] Verified lockfile

After Update:
  [ ] Build passed
  [ ] Type check passed
  [ ] Tests passed
  [ ] Bundle size acceptable (< 10% change)
  [ ] Committed changes
  [ ] Cleanup done
```
