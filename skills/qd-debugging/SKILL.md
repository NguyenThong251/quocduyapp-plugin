---
name: Qd-debugging
description: Universal all-in-one debugger for any project, language, or framework. Detects error category, traces root cause, applies minimal fix, verifies. Covers build, runtime, test, config, integration, and dependency issues.
triggers:
  - /qd-debugging
  - debug
  - fix error
  - analyze error
  - troubleshooting
---

# /qd-debugging

**Universal debugger.** Lam tu dau den cuoi, khong phai huong dan. Doc error, trace root cause, fix, verify.

Khong co gi la "case moi" — chi co "pattern" va "chua biet pattern nao".

---

## Step 1 — Thu Thap Error

Thu thap TU NHIEU NGUON:
- Dev server output
- Build log (`yarn build 2>&1`, `npm run build 2>&1`)
- Browser console / network tab
- Stack trace (neu co)
- Git diff gan day (`git diff HEAD~3 --stat`)

Tra cuu memory project (neu co) xem co gap loi tuong tu chua.

**Dieu quan trong:** Doc error TU NHIEU LAN cho den khi hieu CHAN error do gi.

---

## Step 2 — Phan Loai Error

| Category | Dau hieu | Thu tu fix |
|----------|----------|-----------|
| **Module resolution** | `Module not found`, `Cannot find module` | 1 |
| **Type/compile** | `SyntaxError`, `TypeError`, `Cannot read` | 2 |
| **Dependency conflict** | `peer dep`, `version mismatch`, `EPERM` | 3 |
| **Config/ESM** | `default export`, `import/export`, `__esModule`, `require is not defined` | 4 |
| **Runtime/circular** | `Cannot access X before init`, `undefined is not a function` | 5 |
| **Network/async** | `timeout`, `fetch failed`, `ECONNREFUSED` | 6 |
| **Logic/regression** | Sai ket qua, khong hien thi, loi business logic | 7 |
| **Permission/OS** | `EPERM`, `EACCES`, `ENOENT` | 8 |
| **Lint/IDE** | ESLint false positive, IDE warnings not affecting build/runtime | 9 |

---

## Step 3 — Trace Root Cause (Systematic)

**Khong du doan.** Chung minh.

### Khi khong biet loi gi

1. Git diff: `git diff HEAD~1 --stat` xem thay doi gan nhat
2. Thay doi gi -> loi do day
3. Revert thu -> loi消失 khong
4. Thay doi thu -> loi消失 khong

### Khi biet loi nhung khong biet tai sao

1. Doc file loi (exact line)
2. Trace xem gia tri do tu dau den
3. Log/console gia tri tai diem do
4. Thay doi gia tri -> loi het/chet?

### Khi biet root cause nhung khong biet fix nao

1. Tim file/chu thu tuong tu trong codebase (pattern matching)
2. Tim project / repo tuong tu tren GitHub xem ho fix the nao
3. Tim docs/changelog cua package do

---

## Step 4 — Apply Fix

**Minimal first.** Fix nho nhat co the, verify truoc khi tiep tuc.

**Rule:** 1 fix + 1 verification = 1 round.

### Common Patterns by Category

#### Module Resolution
```
Khong tim thay file -> kiem tra:
  - import path dung chua (case sensitive tren Linux)
  - file extension dung chua (.js vs .jsx)
  - package nao export file do (main/module field)
  - alias path trong config (vite.config.js, tsconfig.json)
```

#### Dependency Conflict
```
peer dep unmet -> yarn add <package>
EPERM lock file -> taskkill + retry
version mismatch -> kiem tra package.json vs lockfile
npm ERR -> xoa node_modules + lockfile + yarn install
```

#### Config/ESM
```
default export undefined -> thu .default hoac ?? export
__esModule namespace -> destructuring dung: obj.default ?? obj
import.meta.url undefined -> kiem tra bundler config
require is not defined -> KHONG dung require() trong ESM browser
  Fix: Thay require() bang static import HOAC dynamic import()
VD: redux-persist ESM -> reduxStorage.default ?? reduxStorage
```

#### Runtime/Circular (TDZ - Temporal Dead Zone)
```
Cannot access X before init -> co circular import HOAC variable usage truoc declaration
  DIAGNOSIS: Kiem tra exact line cua loi. Neu la usage cua mot import
  trong object/array literal o top-level -> day la TDZ.
  Fix: Move object/array map VAO TRONG function (khong phai require())
  VI DU:
    // SAI - bi TDZ
    const moduleMap = { x: ImportX };  // line 10
    import { ImportX } from "./X";       // line 5

    // DUNG - move vao function
    export const Config = () => {
      const moduleMap = { x: ImportX };
      // ...
    };

Note: require() trong function cung bi loi vi ESM khong co require()
  -> Dung static import o top-level + move map usage vao function
undefined is not a function -> function chua defined
  - Kiem tra import dung chua
  - Kiem tra export co ton tai khong
```

#### Network/Async
```
fetch failed -> kiem tra server dang chay chua
  - curl localhost:<port>
  - proxy config dung khong
ECONNREFUSED -> port bi chiếm
  - taskkill process dang dung port do
```

#### Permission/OS
```
EPERM unlink -> process dang lock file
  - Windows: tasklist | grep <process>
  - Close file handlers
ENOENT -> duong dan khong ton tai
  - Kiem tra path (case, slash, typo)
```

#### Lint/IDE False Positives
```
eslint-plugin-react-hooks v7 co stricter rules -> false positives:
  - refs: Accessing ref.current during render (React pattern)
  - immutability: Modifying props/hook arguments (React pattern)
  - exhaustive-deps: Too strict for existing codebase
  FIX: Disable trong eslint.config.js:
    rules: {
      "react-hooks/refs": "off",
      "react-hooks/immutability": "off",
      "react-hooks/exhaustive-deps": "off",
    }
  CHECK RULE NAMES: node -e "const rh = require('eslint-plugin-react-hooks'); console.log(Object.keys(rh.rules));"
```

---

## Step 5 — Verification

Sau fix:

1. Re-run command bi fail
2. Build pass
3. Dev server pass (neu app)
4. Check error da消失 trong output moi

**Neu loi chua het:** quay lai Step 1, nhan dien loi moi.

---

## Step 6 — Iterate

Lap: fix -> verify -> fix tiep neu can.

Dung khi:
- Het loi -> pass
- Dat 3 attempts -> dung, bao cao root cause + defer/workaround

---

## Step 7 — Report

Output:
```
Error: <exact error message>
Category: <phan loai>
Root cause: <giai thich ro rang>
Fix applied: <file + change>
Verification: <build time, output>
Remaining risk: <neu co>
```

---

## Universal Checklist

Khi gap error bat ky:
- [ ] Doc full error message — khong chi nhin error type
- [ ] Doc stack trace — biet exactly tai cho nao
- [ ] Git diff — thay doi gi gan nhat?
- [ ] Restart dev server — loi co biet?
- [ ] Clear cache (`node_modules/.vite`, `.next`, `__pycache__`) — loi con?
- [ ] Reinstall deps (`yarn install`, `pip install`) — loi con?

---

## Ecosystem-Specific Reminders

### Node/Vite/React

#### Vite 8 (Rolldown)
- `esbuildOptions deprecated` -> Rolldown handles JSX, remove esbuildOptions
- `require is not defined` -> ESM browser khong co require(), dung static HOAC dynamic import()
- **TDZ pattern moi**: Static import OK nhung usage trong object literal top-level van bi TDZ
  -> Fix: Move module map object VAO TRONG function
- EPERM -> kill process

#### Vite 8 + @vitejs/plugin-react v6
- JS->JSX transform do plugin-react tu xu ly, khong can custom esbuild plugin
- Dev server co the cache stale code -> restart dev server sau khi fix

#### ESLint Flat Config (v9+)
- File config: `eslint.config.js` (ESM) thay `.eslintrc.cjs`
- Plugin imports phai dung ESM: `import x from "eslint-plugin-x"`
- `@eslint/js` can cai rieng: `import js from "@eslint/js"; export default [js.configs.recommended]`
- Rule prefixing: Khong co `eslint:` prefix trong flat config
- Check plugin rules: `node -e "const rh = require('eslint-plugin-x'); console.log(Object.keys(rh.rules));"`

#### redux-persist ESM
- `storage.getItem is not a function` -> Fix: `reduxStorage.default ?? reduxStorage`

### Python/Django
- `ModuleNotFoundError` -> kiem tra venv activated
- Migration error -> `python manage.py makemigrations`
- Import cycle -> `from .module import` thay vi `import module`

### Go
- `undefined: xxx` -> missing import
- `import cycle not allowed` -> refactor interface
- `cannot find package` -> `go mod tidy`

### .NET/C#
- `CS0246` -> missing using/namespace
- `NU1603` -> NuGet package version warning
- `MSB4018` -> dotnet restore / clean

### PHP/Laravel
- `Class not found` -> `composer dump-autoload`
- `Target class does not exist` -> kiem tra service provider
- `Missing required parameters` -> kiem tra .env

---

## Session Debugging Patterns (Lessons Learned)

### Pattern: require() vs static import vs TDZ

Khi gap `Cannot access X before init` sau khi REVERT `require()`:
- NGUYEN NHAN: moduleMap object dung import truoc khi import duoc khai bao (TDZ)
- Fix: Move moduleMap VAO TRONG function nhu import da o top-level

Khi gap `require is not defined` sau khi THEM `require()`:
- NGUYEN NHAN: ESM browser context khong co `require()`
- Fix: Dung static import o top-level (neu khong bi TDZ) HOAC move usage vao function

### Pattern: ESLint react-hooks v7 False Positives

eslint-plugin-react-hooks v7 them stricter rules:
- `refs` -> "Cannot access refs during render" (false positive, React pattern)
- `immutability` -> "Cannot modify props" (false positive, React pattern)
- `exhaustive-deps` -> "missing dependencies" (false positive, complex hooks)

Fix: Disable trong config, khong phai fix code.

### Pattern: Major Package Upgrade -> Test Branch

Khi upgrade major version (VD: @ant-design/charts 1->2):
1. Tao test branch rieng
2. Upgrade package
3. Build verify
4. Code migrate (config API changes)
5. Commit + push test branch
6. User test in browser
7. Merge chi khi OK

---

## Rules

- Doc error nhieu lan, fix sau.
- Khong fix khi chua trace root cause.
- 1 fix + 1 verify = 1 round.
- Error bat ky deu co root cause — chi can tim ra.
- Khi khong biet -> git diff + revert thu.
- De cuoi: backup roi moi fix.
- ESLint warnings khong anh huong build/runtime -> tinh chat, co the disable.
- Major upgrade -> test branch rieng, khong lam direct tren working branch.
