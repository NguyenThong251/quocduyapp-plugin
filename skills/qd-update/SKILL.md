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
    3. Analyze source code (nếu cần sửa code)
    4. Dev server check (nếu là frontend)
    5. Auto-fix loop (3 attempts) nếu có lỗi
    6. Hiển thị kết quả
    7. Hỏi: push hay rollback?

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

### Step 5.5: Dev Server Runtime Check ⭐

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
      echo "=== Dev Server Log (last 50 lines) ==="
      tail -50 dev-server.log
      echo ""
      # → CHUYỂN SANG Step 5.6: Auto-Fix
    else
      echo "✅ No runtime errors detected"
      echo "   Dev server healthy at $DEV_URL"
    fi
  else
    echo "❌ Dev server failed to start at $DEV_URL"
    echo ""
    echo "=== Dev Server Log (last 50 lines) ==="
    tail -50 dev-server.log
    echo ""
    # → CHUYỂN SANG Step 5.6: Auto-Fix
  fi

  # Dọn dev server trước khi fix
  kill $DEV_PID 2>/dev/null
  wait $DEV_PID 2>/dev/null
  echo "🧹 Dev server stopped"
else
  echo "ℹ️  No dev server detected — skipping runtime check"
fi
```

### Step 5.6: Auto-Fix Loop ⭐ (MỚI)

**NẾU có lỗi → TỰ ĐỘNG FIX thay vì rollback ngay**

```
🔧 ATTEMPTING AUTO-FIX...
   Attempt 1/3: [fix strategy]
```

**Loop 1-3 lần, mỗi lần:**
1. Analyze lỗi từ log
2. Apply fix phù hợp
3. Re-run dev server
4. Re-check — nếu pass → tiếp tục

**CHỈ rollback khi đã thử 3 lần mà vẫn lỗi**

```bash
# Auto-fix loop - thử tối đa 3 lần
FIX_ATTEMPT=0
MAX_FIX_ATTEMPTS=3

while [ $FIX_ATTEMPT -lt $MAX_FIX_ATTEMPTS ]; do
  FIX_ATTEMPT=$((FIX_ATTEMPT + 1))
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  🔧 AUTO-FIX ATTEMPT $FIX_ATTEMPT/$MAX_FIX_ATTEMPTS"
  echo "═══════════════════════════════════════════════════════"

  # Đọc lỗi từ log
  ERRORS=$(tail -100 dev-server.log 2>/dev/null)

  # PHÂN TÍCH LỖI VÀ FIX
  echo "📋 Analyzing errors from dev-server.log..."

  # 1. MISSING DEPENDENCY / MODULE NOT FOUND
  if echo "$ERRORS" | grep -qiE "Module not found|Cannot find module|ENOENT|ERR_MODULE_NOT_FOUND"; then
    MISSING_MODULE=$(echo "$ERRORS" | grep -iE "Module not found|Cannot find module|ENOENT" | grep -oE "'[^']+'|\"[^\"]+\"" | head -1 | tr -d "'\"")
    if [ -n "$MISSING_MODULE" ]; then
      echo "🔍 Missing module detected: $MISSING_MODULE"
      # Thử install missing module
      echo "   Trying to install missing dependency..."
      yarn add "$MISSING_MODULE" 2>/dev/null || npm install "$MISSING_MODULE" 2>/dev/null
      if [ $? -eq 0 ]; then
        echo "✅ Installed: $MISSING_MODULE"
        NEED_RERUN=true
      else
        echo "⚠️  Could not auto-install: $MISSING_MODULE"
      fi
    fi
  fi

  # 2. PEER DEPENDENCY MISSING
  if echo "$ERRORS" | grep -qiE "peer dep|requires a peer|peer dep.*not satisfied"; then
    echo "🔍 Peer dependency issue detected"
    # Extract peer dep name
    PEER_DEP=$(echo "$ERRORS" | grep -iE "requires a peer" | grep -oE "[a-z@/-]+@[0-9.x]+" | head -1)
    if [ -n "$PEER_DEP" ]; then
      echo "   Installing peer dependency: $PEER_DEP"
      yarn add "$PEER_DEP" --dev 2>/dev/null || yarn add "$PEER_DEP" 2>/dev/null
      if [ $? -eq 0 ]; then
        echo "✅ Installed peer dep: $PEER_DEP"
        NEED_RERUN=true
      fi
    fi
  fi

  # 3. DEPRECATED API / REMOVED
  if echo "$ERRORS" | grep -qiE "deprecated|removed|cannot read property|undefined is not"; then
    echo "🔍 Deprecated/removed API detected"
    # Phân tích chi tiết lỗi
    DEPRECATED_ERROR=$(echo "$ERRORS" | grep -iE "deprecated|removed|cannot read" | head -3)
    echo "   Error: $DEPRECATED_ERROR"
    echo ""
    echo "⚠️  Manual fix required for deprecated API"
    echo "   → Run: /qd-outdated to analyze breaking changes"
    echo "   → Then fix code manually following Phase 6 rules"
  fi

  # 4. ESM/COMMONJS MISMATCH
  if echo "$ERRORS" | grep -qiE "ERR_REQUIRE_ESM|require.*esm|dynamic import.*esm"; then
    echo "🔍 ESM/CommonJS mismatch detected"
    # Thử install ESM compatibility
    echo "   Trying ESM compatibility fix..."
    # Check nếu có --experimental-vm-modules hoặc tsconfig changes
    echo "   ℹ️  ESM fix usually requires tsconfig/build config change"
  fi

  # 5. TYPESCRIPT / TYPE ERROR
  if echo "$ERRORS" | grep -qiE "Type error|TypeScript|tc.*error"; then
    echo "🔍 TypeScript error detected"
    echo "   Running type check to get full error list..."
    npx tsc --noEmit 2>&1 | head -30
    echo ""
    echo "⚠️  Type errors need manual fix — run tsc to see all errors"
  fi

  # 6. CONFIG / ENV ERROR
  if echo "$ERRORS" | grep -qiE "config|process\.env|undefined environment"; then
    echo "🔍 Configuration error detected"
    # Check .env file
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
      echo "   Copying .env.example to .env..."
      cp .env.example .env
      echo "✅ Created .env from .env.example"
      NEED_RERUN=true
    fi
  fi

  # NẾU CÓ THAY ĐỔI → RE-RUN DEV SERVER
  if [ "$NEED_RERUN" = true ]; then
    echo ""
    echo "🔄 Re-running dev server to verify fix..."
    $DEV_CMD > dev-server.log 2>&1 &
    DEV_PID=$!
    sleep $DEV_WAIT

    # Kiểm tra lại
    if curl -s --max-time 5 "$DEV_URL" > /dev/null 2>&1; then
      NEW_ERRORS=$(grep -iE "Error:|Uncaught|ReferenceError|TypeError|SyntaxError|Cannot|failed|ENOENT" dev-server.log 2>/dev/null | grep -v "^info:\|^warn:\|^Warning:" | wc -l)
      if [ $NEW_ERRORS -eq 0 ]; then
        echo "✅ FIX SUCCESSFUL — Dev server running without errors"
        kill $DEV_PID 2>/dev/null
        wait $DEV_PID 2>/dev/null
        break
      else
        echo "⚠️  Still has $NEW_ERRORS errors — will retry..."
        kill $DEV_PID 2>/dev/null
        NEED_RERUN=false
      fi
    else
      echo "⚠️  Dev server still not responding — will retry..."
      kill $DEV_PID 2>/dev/null
      NEED_RERUN=false
    fi
  fi
done

# SAU 3 LẦN MÀ VẪN LỖI → ROLLBACK
if [ "$NEED_RERUN" = false ] && [ $FIX_ATTEMPT -ge $MAX_FIX_ATTEMPTS ]; then
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  ❌ AUTO-FIX FAILED AFTER $MAX_FIX_ATTEMPTS ATTEMPTS"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "⚠️  ROLLING BACK — manual fix required"
  echo ""
  echo "   Next steps:"
  echo "   1. Run: /qd-outdated to analyze breaking changes"
  echo "   2. Fix code manually (Phase 6)"
  echo "   3. Run: /qd-update <package> to retry"
  echo ""
  git checkout package.json yarn.lock
  yarn install 2>/dev/null
  echo "⚠️ AUTO-ROLLED BACK"
  exit 1
fi
```

**Summary: Auto-Fix Matrix**

| Error Type | Auto-Fix Action |
|------------|-----------------|
| Missing module (ENOENT) | `yarn add <module>` |
| Peer dependency missing | `yarn add <peer-dep>` |
| Config/env missing | Copy `.env.example` → `.env` |
| Deprecated API | Manual fix required |
| TypeScript error | Manual fix + tsc check |
| ESM mismatch | Manual config change |

---

## Phase 6: Source Code Analysis (BẮT BUỘC khi cần sửa code)

**⚠️ NẾU UPDATE ĐÒI HỎI SỬA CODE — LÀM THEO THỨ TỰ SAU:**

### Step 6.1: Scan Source Codebase (TRƯỚC KHI SỬA BẤT CỨ GÌ)

```bash
echo "📖 Analyzing source codebase structure..."
```

**BẮT BUỘC đọc và hiểu TOÀN BỘ source code trước khi sửa:**

1. **Cấu trúc thư mục** — hiểu layout, cách tổ chức files
2. **Coding style** — indent (2/4 spaces), semicolon, quotes, naming conventions
3. **Logic patterns** — cách viết async/await, error handling, state management
4. **Component patterns** — structure của components, hooks usage, props typing
5. **Naming conventions** — files, functions, variables, constants
6. **Import order** — thứ tự imports (external → internal → relative)

**Cách đọc source:**

```bash
# Đọc tất cả source files
find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \
  ! -path "./node_modules/*" ! -path "./dist/*" ! -path "./build/*" \
  ! -path "./.next/*" ! -path "./coverage/*" \
  -exec echo "=== {} ===" \; -exec head -50 {} \;

# Đọc config files để hiểu conventions
cat tsconfig.json 2>/dev/null
cat eslint.config.js 2>/dev/null || cat .eslintrc* 2>/dev/null
cat prettier.config.js 2>/dev/null || cat .prettierrc* 2>/dev/null
cat package.json | grep -A5 '"scripts"'
```

### Step 6.2: Identify Required Code Changes

```bash
echo "🔍 Identifying required code changes..."
```

**Liệt kê TẤT CẢ những gì cần thay đổi:**

- Breaking API changes (deprecated functions, removed props)
- Import path changes
- Configuration updates
- Migration của logic cũ sang logic mới

### Step 6.3: Apply Code Changes (MATCH 100% STYLE)

**⚠️ SỬA THEO CONVENTION CỦA SOURCE — KHÔNG THEO LIBRARY DOCS MỚI NHẤT**

```bash
# Khi sửa code, phải match:
# - Indentation style (2/4 spaces) — xem tsconfig/eslint
# - Quote style (' vs ") — xem .eslintrc
# - Semicolon usage — xem .eslintrc
# - Import order — xem existing imports
# - Naming: camelCase/PascalCase/kebab-case
# - Async pattern: .then() vs async/await
# - Error handling: try/catch vs .catch()
```

**Ví dụ cách match style:**

```
# Nếu source dùng:
import { useState } from 'react';
const [count, setCount] = useState(0);

# Thì code mới phải VIẾT Y CHƯỚC, không phải:
# import * as React from 'react' (sai style)
# const state = useState(0) (sai naming)
```

### Step 6.4: Verify Code Changes

```bash
echo "✅ Verifying code changes match codebase style..."
yarn lint --fix 2>/dev/null
yarn build 2>&1 | head -20
```

---

## Phase 7: Major Version Strategy (nếu cần)

**Chỉ khi có breaking changes — SAU KHI đã analyze source ở Phase 6:**

```bash
# Thử tìm official codemod
npx <package>-codemod --help 2>/dev/null && {
  echo "🔧 Running codemod..."
  npx <package>-codemod <transform> src/ --dry
  # Review rồi apply nếu user đồng ý
}
```

---

## Phase 8: Preventive Tooling (tùy chọn)

```bash
# Offer nhưng KHÔNG block
echo "🔧 Offer preventive tooling? (y/n)"
```

---

## Phase 9: Commit

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
- ✅ Dev server check cho frontend projects
- ✅ Auto-fix loop (3 attempts) thay vì rollback ngay
- ✅ **Chỉ rollback khi đã thử 3 lần fix mà vẫn lỗi**
- ✅ Mọi thay đổi trên branch riêng — rollback dễ dàng
- ⚠️ **KHI CẦN SỬA CODE — BẮT BUỘC đọc hết source codebase trước** để match style/format/logic chuẩn

---

## Summary Checklist

```
□ Confirm 1 lần duy nhất (Phase 1)
□ Tự động chạy Phase 2-9 (không hỏi)
□ Phân tích source code TRƯỚC khi sửa (Phase 6)
□ Dev server check (Phase 5.5)
□ Auto-fix loop 3 lần trước khi rollback (Phase 5.6)
□ Final prompt: push hay rollback?
```
