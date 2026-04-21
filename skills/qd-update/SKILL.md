---
name: qd-update
description: Execute safe one-by-one dependency updates with research-first checks, verification-loop, language reviewer agents, optional TDD gates, and handoff to qd-debugging when runtime/dev errors appear.
triggers:
  - /qd-update
  - update package
  - safe update
  - upgrade library
---

# /qd-update

Mot lan chi update 1 thu vien. Khong update nhieu package cung luc.

## Core Integrations

- `build-error-resolver`: fix compile/build error sau update.
- `typescript-reviewer` / `python-reviewer` / `go-reviewer`: review compatibility theo ngon ngu.
- `requesting-code-review`: review truoc khi ket thuc update.
- `verification-loop`: build, lint, typecheck, test lap lai sau moi thay doi.
- `tdd-workflow`: tuy chon bat TDD gate de chong regression.
- `ralph` persistence mode tu OMC: tiep tuc fix den khi qua gate hoac dat max-attempt policy.

## Workflow (12 Phases)

### Phase 1 - Intake and single confirmation

Doc `CHANGELOG_DEPENDENCY_UPDATE.md`, xac nhan:

- package name
- from version -> to version
- risk level
- expected migration effort

Neu user khong xac nhan, dung.

### Phase 2 - Preflight (search-first)

Research nhanh truoc khi cham code:

1. Breaking changes summary
2. Migration guide
3. Codemod availability
4. Known runtime issues (dev server, syntax/runtime mismatch)

### Phase 3 - Optional TDD gate

Neu user bat `strict` hoac package risk la major:

1. Viet test reproducer cho critical flow.
2. Chay test phai FAIL truoc (RED).
3. Moi duoc update package.

Neu project khong co test infra: note ro "manual regression mode".

### Phase 4 - Baseline snapshot

Bat buoc:

- Tao branch: `update/<package>-<from>-to-<to>`
- Chay baseline build/test/lint/typecheck
- Luu baseline artifacts logs

### Phase 5 - Update one library

Chay dung command theo package manager.

Neu la major 2+ versions behind: chia phase incremental.

### Phase 6 - Verification loop pass 1

Chay theo thu tu:

1. build
2. typecheck
3. lint
4. tests
5. dev runtime smoke check (neu la app co dev server)

Neu fail compile/build: chuyen Phase 7.
Neu fail runtime/dev syntax: chuyen Phase 8.

### Phase 7 - Compile/build fixer loop

Khi build fail:

1. Goi `build-error-resolver`.
2. Apply fix nho nhat.
3. Chay lai `verification-loop`.
4. Lap toi da 3 lan.

Neu van fail, ho tro rollback/defer.

### Phase 8 - Runtime/dev debugging handoff

Khi build pass nhung dev runtime loi (syntax/API mismatch):

1. Thu thap log (`dev-server.log`, stack traces).
2. Run `/qd-debugging` voi package context + log.
3. Sau khi qd-debugging fix, quay lai Phase 6 verification-loop.

### Phase 9 - Language reviewer pass

Chon reviewer theo codebase:

- TS/JS: `typescript-reviewer`
- Python: `python-reviewer`
- Go: `go-reviewer`

Muc tieu:

- API compatibility
- silent breakage
- typing/runtime mismatch
- migration anti-pattern

### Phase 10 - Requesting code review (global)

Sau language reviewer, chay them flow `requesting-code-review` de co final feedback truoc khi ket.

### Phase 11 - Final gate and decision

Chi coi la pass khi:

- build/type/lint/test pass
- dev runtime check pass (neu applicable)
- reviewer findings critical da duoc xu ly

Sau do hoi 1 cau:

- `push` -> commit/push
- `rollback` -> revert lockfile + dependency changes
- `defer` -> luu backlog

### Phase 12 - Report

Output bat buoc:

- version updated
- issues da gap va cach fix
- logs/chung cu verification
- reviewer summary
- next recommended package

## RALPH-style persistence policy

Khi gap loi kho:

- Khong bo cuoc som.
- Lap analysis -> fix -> verify theo vong.
- Moi vong phai co evidence moi.
- Dung khi:
  - pass het gates, hoac
  - dat max attempts va user chon rollback/defer.

## Rules

- Luon 1 package/lan.
- Khong bo qua verification-loop.
- Khong skip runtime/dev check cho frontend/app.
- Build fail thi uu tien build-error-resolver.
- Runtime fail thi handoff sang `/qd-debugging`.
- Luon co rollback path.
