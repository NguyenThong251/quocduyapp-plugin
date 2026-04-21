---
name: qd-outdated
description: Audit outdated dependencies for multi-language projects, research breaking changes with search-first + documentation-lookup, then generate actionable update plans and roadmap files before any update.
triggers:
  - /qd-outdated
  - check outdated
  - dependency audit
  - changelog dependencies
  - update plan dependencies
---

# /qd-outdated

Audit only. Skill nay khong update package.

## Muc tieu

1. Phat hien dependencies outdated tren nhieu ngon ngu.
2. Research official docs + community signal truoc khi ket luan.
3. Sinh tai lieu de user review truoc khi chay `/qd-update`.

## Core Integrations

- `search-first`: research truoc khi de xuat update strategy.
- `documentation-lookup` (Context7): tra API moi/migration guide theo version.
- `writing-plans`: tao roadmap dang phase + checklist chi tiet.

## 10-Phase Workflow

### Phase 1 - Detect project and manifests

Quet cac file: `package.json`, `composer.json`, `pyproject.toml`, `requirements.txt`, `go.mod`, `Cargo.toml`, `pom.xml`, `build.gradle`, `*.csproj`, `Gemfile`.

Neu co nhieu manifests, audit tung nhom rieng.

### Phase 2 - Detect package manager and run outdated

Chon dung command theo lockfile/manifest:

- Node: `yarn outdated` / `npm outdated` / `pnpm outdated`
- PHP: `composer outdated`
- Python: `pip list --outdated` / `poetry show --outdated`
- Go: `go list -m -u all`
- Rust: `cargo outdated`
- Java: Maven/Gradle dependency updates
- .NET: `dotnet list package --outdated`
- Ruby: `bundle outdated`

### Phase 3 - Source impact scan

Voi tung package outdated:

1. Dem so file dang su dung package.
2. Liet ke usage pattern chinh.
3. Danh gia impact: `low`, `medium`, `high`.

### Phase 4 - Search-first research (bat buoc)

Nghien cuu theo thu tu:

1. Official changelog/release notes.
2. Breaking changes.
3. CVE/security notes.
4. Codemod/migration tooling.
5. Community signals (GitHub issues, StackOverflow, Reddit, Dev.to).

### Phase 5 - Documentation lookup via Context7 (bat buoc cho major)

Khi co major update hoac API thay doi:

1. Resolve library ID.
2. Query docs cho migration/API moi.
3. Trich snippet migration quan trong vao bao cao.

### Phase 6 - Risk classification

- `Critical`: CVE/security urgent.
- `Major`: co breaking changes.
- `Minor`: behavior/feature changes co kha nang anh huong.
- `Patch`: low-risk.

### Phase 7 - Decision matrix

Moi package phai co:

- Benefit vs cost.
- Estimated effort.
- Test scope de xuat.
- Rollback complexity.
- Verdict: `upgrade-now` / `upgrade-with-care` / `defer`.

### Phase 8 - Generate plan docs (writing-plans style)

Luon sinh 2 file:

1. `CHANGELOG_DEPENDENCY_UPDATE.md`
2. `UPDATE-ROADMAP.md`

`UPDATE-ROADMAP.md` bat buoc co:

- Phase-by-phase command.
- Verification gate sau tung phase.
- Stop/rollback criteria.
- Uoc luong effort theo package.

### Phase 9 - Recommend execution path

Thu tu de xuat:

1. Security updates.
2. Low-risk patch/minor.
3. Major updates (phased).
4. Deferred backlog.

### Phase 10 - Handoff to qd-update and qd-debugging

Report ket thuc phai chi ro:

- Package nao chay truc tiep `/qd-update`.
- Package nao nen chay `/qd-update` + `/qd-debugging` ngay sau update.

## Required Output Template

```markdown
# CHANGELOG: Dependency Update Report

## Executive Summary
- Total packages: X
- Outdated: Y
- Critical/Major/Minor/Patch: A/B/C/D

## Package Analysis
### <package> <old> -> <new>
- Risk:
- Source impact:
- Breaking changes:
- Context7 migration notes:
- Community warnings:
- Recommendation:

## Recommended Execution Order
1. ...
2. ...

## Handoff
- Run: /qd-update <package>
- If runtime/build/dev errors: run /qd-debugging
```

## Rules

- Luon research truoc khi ket luan (search-first).
- Luon tra docs moi cho major (documentation-lookup).
- Luon tao changelog + roadmap (writing-plans style).
- Khong update package trong skill nay.
