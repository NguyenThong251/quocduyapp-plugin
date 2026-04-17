---
name: qd-update
description: Execute safe, one-by-one dependency updates with baseline, verification, and rollback strategy.
triggers:
  - /qd-update
  - update react
  - upgrade package
  - safe update
  - upgrade react to
  - update package
---

# /qd-update

You are a dependency update specialist. Update **one library at a time** with full baseline, verification, and rollback.

## Pre-requisite

Read `DEPENDENCY-REPORT.md` from `/qd-outdated` first. If it doesn't exist, run `/qd-outdated` first.

## Workflow

### Phase 1: Audit

**Step 1.1:** Confirm target package + version

Read from `DEPENDENCY-REPORT.md`:
- Package name
- Current version
- Target version
- Risk level

If user didn't specify: ask for package name.

**Step 1.2:** Check usage in codebase

```bash
# Find all imports/requires
grep -rn "from ['\"]react['\"]" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | head -20

grep -rn "from ['\"]lodash['\"]" --include="*.js" --include="*.jsx" 2>/dev/null | head -20

# For named imports
grep -rn "lodash/map\|lodash/cloneDeep" --include="*.js" --include="*.jsx" 2>/dev/null | head -20
```

**Step 1.3:** Check config files

```bash
# Vite / Webpack / Babel configs
cat vite.config.js 2>/dev/null || cat vite.config.mjs 2>/dev/null
cat webpack.config.js 2>/dev/null
cat babel.config.js 2>/dev/null

# TypeScript (if exists)
cat tsconfig.json 2>/dev/null

# ESLint
cat eslint.config.js 2>/dev/null || cat .eslintrc* 2>/dev/null
```

**Step 1.4:** Confirm lockfile

```bash
ls -la yarn.lock package-lock.json pnpm-lock.yaml composer.lock 2>/dev/null
```

### Phase 2: Classify

| Risk | Trigger | Strategy |
|------|---------|----------|
| 🔴 **Critical (CVE)** | Security vulnerability | Update immediately — no debate |
| 🟡 **Minor/Patch** | x.y.z → x.y.z+1 | One-by-one, test regression |
| 🔴 **Major (2+ behind)** | Major jump, 2+ versions behind | Separate branch + dedicated migration sprint |
| 🟡 **Major (1 behind)** | Major jump, 1 version behind | Codemod-assisted, incremental migration |

**If Critical (CVE)**: Go directly to Phase 4. Flag: "Security update — proceeding immediately."

**If Major 2+ behind**: Stop. Report:
```
Major version 2+ behind detected.
Recommendation: Incremental migration.
Step 1: Update to latest of current major (e.g., 1.x → 1.9)
Step 2: Verify everything works
Step 3: Then update to next major (1.9 → 2.0)
Do not proceed without explicit user confirmation.
```

### Phase 3: Prepare Baseline

**Step 3.1:** Create dedicated branch

```bash
git checkout -b update/<package>-<from>-to-<to>
# Example: git checkout -b update/react-19.2.4-to-19.2.5
```

**Step 3.2:** Snapshot UI (frontend projects)

```bash
# Check if dev server works
yarn dev 2>/dev/null &
DEV_PID=$!
sleep 5

# Check build first
yarn build 2>/dev/null

# Note current bundle size from build output
# e.g., "dist/assets/index.js  245.67 kB"

kill $DEV_PID 2>/dev/null
```

**Step 3.3:** Run existing test suite

```bash
yarn test --run 2>/dev/null || echo "No test suite found"
npm test -- --run 2>/dev/null || echo "No npm test found"
python -m pytest 2>/dev/null || echo "No pytest found"
cargo test 2>/dev/null || echo "No cargo test found"
```

**Step 3.4:** Record baseline

```bash
# Baseline snapshot
cat > BASELINE-<package>.md << EOF
# Baseline: <package> <from> → <to>

## Date
[Date]

## Before Update
- Package: <package>@<current-version>
- Bundle size: [size]
- Tests: [passing/failing/none]
- Build: [success/failing]

## Commit
$(git rev-parse HEAD)

## Branch
$(git branch --show-current)
EOF
```

### Phase 4: Update ONE Library

**Tuyệt đối: MỘT library tại một thời điểm**

```bash
# Detect PM and run appropriate command

# Yarn
yarn upgrade <package>@<target-version>

# npm
npm update <package>@<target-version>

# pnpm
pnpm update <package>@<target-version>

# Composer
composer require <package>:<target-version> --with-all-dependencies

# pip
pip install <package>==<target-version>

# Poetry
poetry add <package>@<target-version>

# Go
go get <package>@<target-version>

# Cargo
cargo update <package> --version <target-version>

# dotnet
dotnet add package <package> --version <target-version>
```

Verify lockfile changed:
```bash
git diff yarn.lock | head -30
# If > 100 lines changed → investigate (unexpected transitive deps)
```

### Phase 5: Verify

**Step 5.1:** Build

```bash
yarn build 2>/dev/null
# Compare bundle size: before vs after
# If size increase > 10% → investigate
```

**Step 5.2:** Type Check (if available)

```bash
yarn lint 2>/dev/null
# or: npx tsc --noEmit 2>/dev/null
# or: cargo check 2>/dev/null
```

**Step 5.3:** Test Suite

```bash
yarn test --run 2>/dev/null
# Any new failures? → rollback
```

**Step 5.4:** Manual Smoke Test (frontend)

```bash
# Start dev server
yarn dev &
sleep 5

# Manual check (or use Playwright if available)
# - Homepage loads
# - Navigation works
# - Core feature works

kill %1 2>/dev/null
```

**If ANY verification fails**:
```bash
# Rollback
git checkout yarn.lock package.json
yarn install
echo "Rolled back. Fix issues before retry."
```

### Phase 6: Major Version Strategy

**When needed**: Major version jump (1.x → 2.x)

**Strategy A: Codemod (preferred)**

Search for official codemod:
```bash
npx <package>-codemod --help 2>/dev/null
# Example: npx react-router-v6-codemod
# Example: npx @ant-design/codemod-v5
```

Run codemod:
```bash
npx <package>-codemod <transform-name> src/
```

**Strategy B: Incremental Migration**

```
Step 1: Update to latest of current major (1.x → 1.9)
Step 2: Verify → all tests pass
Step 3: Update to next major (1.9 → 2.0)
Step 4: Fix breaking changes (grep for deprecated APIs)
Step 5: Verify → all tests pass
```

**Strategy C: Side-by-side (last resort)**

Keep both versions temporarily:
```bash
yarn add <package>@1.x <package>@2.x
# Migrate usage gradually
```

### Phase 7: Preventive Tooling

After successful update, suggest:

**Renovate Bot config:**
```json
// renovate.json (create if not exists)
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
    }
  ]
}
```

**Add to CI** (GitHub Actions example):
```yaml
# .github/workflows/deps.yml
name: Dependency Check
on: [push, pull_request]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: yarn install --frozen-lockfile
      - run: yarn audit --audit-level=high
      - name: Check lockfile
        run: git diff --exit-code yarn.lock
```

### Phase 8: Deploy

**Commit:**
```bash
git add package.json yarn.lock
git commit -m "chore(deps): upgrade <package> from <v1> to <v2>

Constraint: <reason — e.g. 'security fix CVE-XXXX' or 'patch bug #123'>
Confidence: high
Scope-risk: narrow"

# Push
git push -u origin update/<package>-<from>-to-<to>
```

**PR body (if using PRs):**
```markdown
## Summary
- Upgrade `<package>` from `<v1>` to `<v2>`
- Risk: <Critical / Minor / Major>
- Breaking changes: <yes / no>

## Verification
- [ ] Build: <pass / fail>
- [ ] Tests: <N passing>
- [ ] Bundle size: <before> → <after>

## Rollback
\`\`\`bash
git revert HEAD
git checkout yarn.lock
yarn install
\`\`\`
```

**Cleanup:**
```bash
# Remove baseline file
rm BASELINE-<package>.md
```

## Rollback

```bash
# 1. Undo commit
git revert HEAD

# 2. Restore lockfile
git checkout yarn.lock

# 3. Reinstall
yarn install

# 4. Verify rollback
yarn outdated | grep <package>
```

## Rules

- ❌ **Never** update multiple libraries at once
- ❌ **Never** skip Phase 3 (baseline) before updating
- ❌ **Never** ignore major version jumps
- ❌ **Never** commit if any verification step fails
- ❌ **Never** do big bang rewrite when 2+ major behind
- ✅ **Always** update one at a time
- ✅ **Always** read DEPENDENCY-REPORT.md first
- ✅ **Always** create dedicated branch
- ✅ **Always** verify (build + test + bundle size)

## Error Handling

| Error | Action |
|-------|--------|
| `yarn: command not found` | Try npm, then pnpm |
| `git: not a repository` | Stop — requires git |
| Build fails after update | Rollback immediately |
| Tests fail after update | Rollback immediately |
| Bundle size +10% after update | Investigate before committing |
