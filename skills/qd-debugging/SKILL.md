---
name: qd-debugging
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

## Step 1 — Thu Thap Error

Thu thap TU NHIEU NGUON:
- Dev server output
- Build log (`yarn build 2>&1`, `npm run build 2>&1`)
- Browser console / network tab
- Stack trace (neu co)
- Git diff gan day (`git diff HEAD~3 --stat`)

Tra cuu memory project (neu co) xem co gap loi tuong tu chua.

**Dieu quan trong:** Doc error TU NHIEU LAN cho den khi hieu CHAN error do gi.

## Step 2 — Phan Loai Error

| Category | Dau hieu | Thu tu fix |
|----------|----------|-----------|
| **Module resolution** | `Module not found`, `Cannot find module` | 1 |
| **Type/compile** | `SyntaxError`, `TypeError`, `Cannot read` | 2 |
| **Dependency conflict** | `peer dep`, `version mismatch`, `EPERM` | 3 |
| **Config/ESM** | `default export`, `import/export`, `__esModule` | 4 |
| **Runtime/circular** | `Cannot access X before init`, `undefined is not a function` | 5 |
| **Network/async** | `timeout`, `fetch failed`, `ECONNREFUSED` | 6 |
| **Logic/regression** | Sai ket qua,khong hien thi, loi business logic | 7 |
| **Permission/OS** | `EPERM`, `EACCES`, `ENOENT` | 8 |

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
```
VD: redux-persist ESM -> `reduxStorage.default ?? reduxStorage`

#### Runtime/Circular
```
Cannot access X before init -> co circular import
  - Move usage cua X vao function (lazy require)
  - Hoac break chain bang refactor
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

## Step 5 — Verification

Sau fix:

1. Re-run command bi fail
2. Build pass
3. Dev server pass (neu app)
4. Check error da消失 trong output moi

**Neu loi chua het:** quay lai Step 1, nhan dien loi moi.

## Step 6 — Iterate

Lap: fix -> verify -> fix tiep neu can.

Dung khi:
- Het loi -> pass
- Dat 3 attempts -> dung, bao cao root cause + defer/workaround

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

## Universal Checklist

Khi gap error bat ky:
- [ ] Doc full error message — khong chi nhin error type
- [ ] Doc stack trace — biet exactly tai cho nao
- [ ] Git diff — thay doi gi gan nhat?
- [ ] Restart dev server — loi co biet?
- [ ] Clear cache (`node_modules/.vite`, `.next`, `__pycache__`) — loi con?
- [ ] Reinstall deps (`yarn install`, `pip install`) — loi con?

## Ecosystem-Specific Reminders

### Node/Vite/React
- `esbuildOptions deprecated` -> Vite 8 Rolldown
- `redux-persist` ESM -> check default export
- Circular TDZ -> lazy require/import
- EPERM -> kill process

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

## Rules

- Doc error nhieu lan, fix sau.
- Khong fix khi chua trace root cause.
- 1 fix + 1 verify = 1 round.
- Error bat ky deu co root cause — chi can tim ra.
- Khi khong biet -> git diff + revert thu.
- De cuoi: backup roi moi fix.
