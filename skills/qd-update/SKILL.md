---
name: qd-update
description: Execute safe, one-by-one dependency updates with automated verification and one-click push/rollback decision.
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

Bạn là **middle-senior software developer** chuyên quản lý dependency và upgrade library. Một library tại một thời điểm, tự động làm hết tất cả verification, chỉ hỏi **1 lần duy nhất** ở cuối: push hay rollback.

---

## Confirmation Workflow (CHỈ 1 LẦN)

```
User runs: /qd-update react

Step 1: Read CHANGELOG_DEPENDENCY_UPDATE.md
         ↓
Step 2: Show summary + ONE confirmation prompt
         ↓
User types: "yes"
         ↓
Step 3: Automated workflow (Phase 1-8) — NO interruption
         ↓
Step 4: Report ALL results
         ↓
Step 5: ONE final decision prompt
  "✅ All checks passed. Push now or rollback?"
  "push"   → commit + push
  "rollback" → revert + restore
```

**Nếu verification fail ở bất kỳ bước nào → TỰ ĐỘNG ROLLBACK → hỏi:**

```
⚠️ VERIFICATION FAILED — AUTO-ROLLED BACK

Error: [build/test/dev server failed]
Fix: [hints]

Retry? /qd-update <package>
```

---

## Phase 1: Audit & Confirm (1 prompt duy nhất)

**Step 1.1: Read CHANGELOG_DEPENDENCY_UPDATE.md**

```bash
cat CHANGELOG_DEPENDENCY_UPDATE.md 2>/dev/null || echo "CHANGELOG_DEPENDENCY_UPDATE.md not found. Run /qd-outdated first."
```

**Step 1.2: Detect package manager**

```bash
if [ -f "yarn.lock" ]; then PM=yarn
elif [ -f "pnpm-lock.yaml" ]; then PM=pnpm
elif [ -f "package-lock.json" ]; then PM=npm
elif [ -f "composer.lock" ]; then PM=composer
elif [ -f "poetry.lock" ]; then PM=poetry
elif [ -f "go.sum" ]; then PM=go
elif [ -f "Cargo.lock" ]; then PM=cargo
fi
```

**Step 1.3: Check current usage**

```bash
grep -rn "from ['\"]react['\"]" --include="*.js" --include="*.jsx" --include="*.ts" --include="*.tsx" 2>/dev/null | wc -l
```

**Step 1.4: Detect project type (for dev server check)**

```bash
if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ] || [ -f "vite.config.mjs" ]; then
  DEV_CMD="yarn dev"
  DEV_URL="http://localhost:5173"
  DEV_WAIT=8
elif [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
  DEV_CMD="yarn dev"
  DEV_URL="http://localhost:3000"
  DEV_WAIT=15
elif [ -f "package.json" ] && grep -q '"start"' package.json; then
  DEV_CMD="yarn start"
  DEV_URL="http://localhost:3000"
  DEV_WAIT=10
fi
```

**Step 1.5: Extract info và hiển thị confirmation**

```
═══════════════════════════════════════════════════════════
  📦 UPDATE REQUESTED: [package-name]
═══════════════════════════════════════════════════════════

Current Version:  [v1.x.x]
Target Version:   [v2.x.x]
Risk Level:       [Critical / Major / Minor / Patch]
Package Manager:  [yarn / npm / etc.]
Dev Server:       [yarn dev / yarn start / none]

Breaking Changes:  [Yes / No]
  - [Breaking change 1]
  - [Breaking change 2]

───────────────────────────────────────────────────────────

⚠️  Automated workflow sẽ:
    1. Tạo branch riêng
    2. Chạy build + tests
    3. [Dev server check nếu là frontend]
    4. Hiển thị kết quả
    5. Hỏi: push hay rollback?

───────────────────────────────────────────────────────────

Type "yes"  → Bắt đầu update tự động
Type "skip" → Hủy
```

---

## Phase 2: Classify Risk

| Risk | Trigger | Action |
|------|---------|--------|
| 🔴 **Critical (CVE)** | Security vuln | Update immediately |
| 🔴 **Major (2+ behind)** | 2+ major versions | **Dừng** — báo incremental migration |
| 🟡 **Major (1 behind)** | 1 major jump | Codemod-assisted |
| 🟡 **Minor** | Minor version | Test regression |
| 🟢 **Patch** | Patch version | Safe to update |

**Nếu Major 2+ behind → Dừng, hỏi user muốn incremental hay skip:**

```
⚠️ MAJOR VERSION 2+ BEHIND DETECTED

[package] is [N] major versions behind.
Khuyến nghị: INCREMENTAL MIGRATION

Type "incremental" → Bắt đầu migration từng bước
Type "skip" → Hủy
```

---

## Phase 3: Prepare Baseline

```bash
# 1. Tạo branch
git checkout -b update/<package>-<from>-to-<to>

# 2. Baseline file
cat > BASELINE-<package>.md << 'EOF'
# Baseline: <package> <from> → <to>
## Date: $(date '+%Y-%m-%d %H:%M')
## Before: <package>@<from>
## Commit: $(git rev-parse HEAD)
EOF

# 3. Measure bundle TRƯỚC
if grep -q '"build"' package.json; then
  echo "📦 Measuring baseline bundle..."
  yarn build 2>&1 | tee build-before.log
fi

# 4. Run tests TRƯỚC
echo "🧪 Running baseline tests..."
yarn test --run 2>/dev/null | tee test-before.log || echo "No test suite"

echo "✅ Baseline recorded"
```

---

## Phase 4: Update ONE Library

**⚠️ CHỈ 1 LIBRARY — KHÔNG BAO GIỜ NHIỀU HƠN**

```bash
# Yarn
yarn upgrade <package>@<target-version>

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

---

## Phase 5: Verify (TỰ ĐỘNG — KHÔNG HỎI)

### Step 5.1: Build

```bash
echo "🔨 Running build..."
yarn build 2>&1 | tee build-after.log
BUILD_RESULT=$?

if [ $BUILD_RESULT -ne 0 ]; then
  echo "❌ BUILD FAILED"
  # AUTO ROLLBACK
  git checkout package.json yarn.lock
  yarn install 2>/dev/null
  echo "⚠️ AUTO-ROLLED BACK to original state"
  exit 1
fi
echo "✅ Build passed"
```

### Step 5.2: Bundle Size Check

```bash
if [ -f "build-before.log" ] && [ -f "build-after.log" ]; then
  echo "📊 Bundle size comparison..."
  echo "BEFORE:"
  ls -la dist/assets/*.js 2>/dev/null | awk '{print $5, $9}'
  echo "AFTER:"
  ls -la dist/assets/*.js 2>/dev/null | awk '{print $5, $9}'
fi
```

### Step 5.3: Type Check

```bash
echo "🔍 Running type check..."
yarn lint 2>/dev/null || npx tsc --noEmit 2>/dev/null || echo "⚠️  No type check configured"
```

### Step 5.4: Run Tests

```bash
echo "🧪 Running tests..."
yarn test --run 2>/dev/null | tee test-after.log
TEST_RESULT=$?

if [ $TEST_RESULT -ne 0 ] && [ -s test-after.log ]; then
  echo "❌ TESTS FAILED"
  # AUTO ROLLBACK
  git checkout package.json yarn.lock
  yarn install 2>/dev/null
  echo "⚠️ AUTO-ROLLED BACK — tests failed"
  exit 1
fi
echo "✅ Tests passed"
```

### Step 5.5: Dev Server Runtime Check ⭐ (MỚI)

**Chỉ chạy nếu project là frontend (vite, next, react-scripts)**

```bash
# Chỉ chạy nếu có dev server
if [ -n "$DEV_CMD" ]; then
  echo "🖥️  Starting dev server for runtime check..."
  echo "   Command: $DEV_CMD"
  echo "   URL: $DEV_URL"
  echo "   Waiting ${DEV_WAIT}s for server to start..."

  # Bắt đầu dev server
  $DEV_CMD > dev-server.log 2>&1 &
  DEV_PID=$!

  # Đợi server khởi động
  sleep $DEV_WAIT

  # Kiểm tra server có chạy không
  if curl -s --max-time 5 "$DEV_URL" > /dev/null 2>&1; then
    echo "✅ Dev server is running at $DEV_URL"

    # Lấy HTML và kiểm tra console error trong log
    echo "📋 Checking dev server logs for errors..."

    ERROR_COUNT=0

    # Common runtime error patterns
    if grep -iE "Error:|Uncaught|ReferenceError|TypeError|SyntaxError|Cannot|failed|ENOENT|Module not found" dev-server.log 2>/dev/null | grep -v "^info:\|^warn:\|^Warning:" > /dev/null; then
      ERROR_COUNT=$(grep -iE "Error:|Uncaught|ReferenceError|TypeError|SyntaxError|Cannot|failed|ENOENT|Module not found" dev-server.log 2>/dev/null | grep -v "^info:\|^warn:\|^Warning:" | wc -l)
    fi

    # Kiểm tra HMR/cold start errors
    if grep -iE "HMR|hot reload|cold start" dev-server.log 2>/dev/null | grep -iE "error|failed" > /dev/null; then
      ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [ $ERROR_COUNT -gt 0 ]; then
      echo "❌ DEV SERVER ERRORS DETECTED ($ERROR_COUNT issues)"
      echo ""
      echo "=== Dev Server Log (last 30 lines) ==="
      tail -30 dev-server.log
      echo ""
      echo "⚠️  RUNTIME ERRORS FOUND — AUTO-ROLLING BACK"
      kill $DEV_PID 2>/dev/null
      git checkout package.json yarn.lock
      yarn install 2>/dev/null
      echo "⚠️ AUTO-ROLLED BACK"
      exit 1
    else
      echo "✅ No runtime errors detected"
      echo "   Dev server healthy at $DEV_URL"
    fi
  else
    echo "❌ Dev server failed to start at $DEV_URL"
    echo ""
    echo "=== Dev Server Log (last 30 lines) ==="
    tail -30 dev-server.log
    kill $DEV_PID 2>/dev/null
    git checkout package.json yarn.lock
    yarn install 2>/dev/null
    echo "⚠️ AUTO-ROLLED BACK — dev server failed to start"
    exit 1
  fi

  # Dọn dev server
  kill $DEV_PID 2>/dev/null
  wait $DEV_PID 2>/dev/null
  echo "🧹 Dev server stopped"
else
  echo "ℹ️  No dev server detected — skipping runtime check"
fi
```

---

## Phase 6: Major Version Strategy (nếu cần)

**Chỉ khi có breaking changes:**

```bash
# Thử tìm official codemod
npx <package>-codemod --help 2>/dev/null && {
  echo "🔧 Running codemod..."
  npx <package>-codemod <transform> src/ --dry
  # Review rồi apply nếu user đồng ý
}
```

---

## Phase 7: Preventive Tooling (tùy chọn)

```bash
# Offer nhưng KHÔNG block
echo "🔧 Offer preventive tooling? (y/n)"
```

---

## Phase 8: Commit

```bash
git add package.json yarn.lock
git commit -m "chore(deps): upgrade <package> from <v1> to <v2>

<Package> <breaking changes / bug fix / security fix>.

Constraint: <reason>
Breaking: <yes / no>
Confidence: high
Scope-risk: narrow"
```

---

## FINAL PROMPT — CHỈ 1 CÂU HỎI

```
═══════════════════════════════════════════════════════════
  ✅ UPDATE SUCCESSFUL: [package] [v1] → [v2]
═══════════════════════════════════════════════════════════

  Branch:    update/<package>-<from>-to-<to>
  Build:     ✅ Pass
  Tests:     ✅ [N passing]
  Dev:       ✅ No runtime errors

───────────────────────────────────────────────────────────

  Type "push"     → Commit & push to remote
  Type "rollback" → Revert to original state

  (Default: push sau 30s nếu không reply)
```

**Khi user gõ "push":**

```bash
git push -u origin update/<package>-<from>-to-<to>
echo "✅ Pushed to remote"
echo "📋 Create PR: gh pr create --fill"
```

**Khi user gõ "rollback":**

```bash
git revert HEAD
git checkout yarn.lock package.json
yarn install 2>/dev/null
echo "✅ Rolled back — original state restored"
```

---

## Auto-Rollback Triggers

| Trigger | Action |
|---------|--------|
| Build fails | **AUTO ROLLBACK** |
| Tests fail | **AUTO ROLLBACK** |
| Dev server dies | **AUTO ROLLBACK** |
| Runtime errors detected | **AUTO ROLLBACK** |
| Bundle +20% | **WARN** — ask user |

---

## Rollback Strategy

```bash
# Manual rollback
git revert HEAD
git checkout yarn.lock package.json
yarn install 2>/dev/null
```

---

## Rules

- ❌ Không hỏi nhiều lần — chỉ 1 prompt đầu + 1 prompt cuối
- ❌ Không update nhiều library cùng lúc
- ❌ Không skip verification
- ✅ Tự động rollback nếu bất kỳ check nào fail
- ✅ Dev server check cho frontend projects
- ✅ Mọi thay đổi trên branch riêng — rollback dễ dàng

---

## Summary Checklist

```
□ Confirm 1 lần duy nhất (Phase 1)
□ Tự động chạy Phase 2-7 (không hỏi)
□ Tự động rollback nếu fail
□ Final prompt: push hay rollback?
```
