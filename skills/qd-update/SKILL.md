---
name: qd-update
description: All-in-one dependency update workflow — research-first, verifies build+dev runtime, auto-detects known breaking patterns (Vite 8, redux-persist, circular deps), fixes found issues, delivers push/merge decision.
triggers:
  - /qd-update
  - update package
  - upgrade library
  - dependency update
---

# /qd-update

**All-in-one.** Chi update 1 package/lan. Khong phai huong dan — lam tu dau den cuoi.

## Phase 1 — Intake

Doc `CHANGELOG_DEPENDENCY_UPDATE.md` neu co. Neu khong co, tu doc `package.json`.

Xac nhan voi user:
- Package + from version -> to version
- Risk level (patch/minor/major)
- Migration effort (none/minor/major)

Neu user khong xac nhan -> dung.

## Phase 2 — Research

Truoc khi cham code:

1. Doc changelog cua package (npm/changelog url)
2. Check breaking changes
3. Check migration guide (codemod available?)
4. Check known runtime issues (tra cuu memory project + common patterns ben duoi)

## Phase 3 — Pre-Detection (Auto)

Neu la Vite hoac React/React-DOM update:

### Vite update (bat ky version nao)

Kiem tra `vite.config.js`:
- Co `esbuildOptions` khong? -> Vite 8 se bao deprecated (Rolldown thay esbuild)
- Co custom JS->JSX plugin trong `optimizeDeps.esbuildOptions` khong?
  - `@vitejs/plugin-react` v6 tu xu ly -> remove plugin + `esbuildOptions`
- **Action:** Neu co, migrate config truoc khi update

### React update

Check:
- `redux-persist` co dung `import storage from "redux-persist/lib/storage"` khong?
  - Fix: `storage: reduxStorage.default ?? reduxStorage`
- `react-cookie` co dung pattern nao can kiem tra khong?

## Phase 4 — Branch + Baseline

- Tao branch: `update/<package>-<from>-to-<to>`
  - Neu la major/high-risk update: tao branch test rieng, chi merge khi user xac nhan
- Chay `yarn build` (hoac `npm run build`) -> luu baseline

## Phase 5 — Update

```bash
# Node
yarn add <package>@<version>        # dependencies
yarn add -D <package>@<version>     # devDependencies

# Python
pip install --upgrade <package>

# Go
go get <package>@latest

# PHP
composer update <package>
```

Neu major 2+ versions behind: incremental (VD: 1.0 -> 1.5 -> 2.0).

## Phase 6 — Verification Loop

### Build
```bash
yarn build 2>&1 | tail -5
```

### Dev server (neu la frontend/app)
```bash
timeout 15 yarn dev 2>&1 | head -20
```
Hoac bat dev server, check output xem co loi khong.

### Runtime check
- Mo browser / check dev server output
- Tim cac loi thuong gap:
  - `Cannot access 'X' before initialization` -> circular dependency (xem Phase 3 detection)
  - `storage.getItem is not a function` -> redux-persist ESM issue
  - Module not found -> missing peer dependency
  - Syntax error -> breaking API change

## Phase 7 — Auto-Fix Common Patterns

Neu gap loi, check theo thu tu:

### Circular Dependency (Vite 8 Rolldown)

**Dau hieu:** `Cannot access 'X' before initialization` o JSX file, build pass nhung dev runtime fail.

**Root cause:** Vite 8 Rolldown evaluate modules stricter. Pattern thuong gap:

File A top-level imports File B, File B imports File C, File C imports function tu File A.

**Fix:** Move static imports + usage object vao trong function (lazy evaluate):

```js
// CU (bi TDZ)
import { X } from "./X";
const map = { x: X };
export const Config = () => { /* dung map */ };

// Moi (lazy)
export const Config = () => {
  const { X } = require("./X"); // hoac async import()
  const map = { x: X };
  // ...
};
```

### redux-persist Storage (Vite 8 ESM)

**Dau hieu:** `storage.getItem is not a function`

**Fix:**
```js
// Cu
import storage from "redux-persist/lib/storage";

// Moi
import reduxStorage from "redux-persist/lib/storage";
const persistConfig = { storage: reduxStorage.default ?? reduxStorage };
```

### Vite esbuildOptions deprecated

**Dau hieu:** `You or a plugin you are using have set optimizeDeps.esbuildOptions but this option is now deprecated`

**Fix:**
```js
// Cu
optimizeDeps: {
  esbuildOptions: { plugins: [...], loader: { ".js": "jsx" } },
},

// Moi
optimizeDeps: {
  include: [], // hoac scoped deps
},
// @vitejs/plugin-react v6+ tu xu ly JS->JSX
```

### Peer Dependency

**Dau hieu:** `unmet peer dependency` warnings

**Fix:** Install them:
```bash
yarn add <peer-package>
```

## Phase 8 — Language Review (Auto)

- TS/JS: goi `typescript-reviewer`
- Python: goi `python-reviewer`
- Go: goi `go-reviewer`

Review: API compatibility, silent breakage, typing issues.

## Phase 9 — Final Verification

- `yarn build` pass
- `yarn dev` pass (khong loi)
- Khong con errors cung loai

## Phase 10 — Decision

Neu test branch (VD: update/vite-8-phase2):
- `merge` -> merge vao ai-dev + push + xoa branch
- `rollback` -> git checkout ai-dev + yarn install + xoa branch

Neu working branch:
- `push` -> commit + push

Moi truong hop deu xoa `dist/`, cleanup.

## Phase 11 — Report

Output:
- Package updated: X Y -> Z
- Issues found + fixes
- Verification evidence (build time, dev output)
- Next recommended package

## Common Breaking Patterns (Built-in Knowledge)

### Node/Vite Projects

| Pattern | Dau hieu | Fix |
|---------|----------|-----|
| Vite 8 esbuildOptions deprecated | Warning "deprecated" | Remove, dùng Rolldown |
| redux-persist ESM | `storage.getItem is not a function` | `reduxStorage.default ?? reduxStorage` |
| Circular TDZ (Vite 8 stricter) | `Cannot access X before init` | Lazy require/import trong function |
| ESLint 10 flat config | `.eslintrc.*` not supported | Migrate to `eslint.config.js` |
| React 19 new hooks API | Hook warnings/errors | Check react-dom version match |
| ant-design v5->v6 | ConfigProvider/Form API | Check changelog |

### Python Projects

| Pattern | Dau hieu | Fix |
|---------|----------|-----|
| Django 4.0+ | `STATICFILES` removed | Update settings |
| FastAPI 0.100+ | Pydantic v2 | `from pydantic import` changes |
| SQLAlchemy 2.0 | ORM patterns | Async session changes |

## Rules

- 1 package/lan.
- Build pass + dev runtime pass = mo gate.
- Runtime fail -> fix theo common patterns -> restart verification.
- Major update -> test branch rieng.
- Luon co rollback path.
