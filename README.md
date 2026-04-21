# quocduyapp-plugin

[![npm version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/NguyenThong251/quocduyapp-plugin)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Supported Languages](https://img.shields.io/badge/languages-9-orange)](https://github.com/NguyenThong251/quocduyapp-plugin)

> Dependency management skills for Claude Code. Audit outdated dependencies and execute safe, one-by-one updates across any language.

[Get Started](#quick-start) • [Skills](#skills) • [Install](#install) • [Supported Languages](#supported-languages)

---

## Overview

**quocduyapp-plugin** cung cấp 3 skills chuyên về dependency lifecycle cho Claude Code:

| Skill | Trigger | Mô tả |
|-------|---------|--------|
| `/qd-outdated` | "check outdated", "dependency audit" | Audit tất cả thư viện, sinh CHANGELOG để review |
| `/qd-update` | "update react", "upgrade [package]" | Thực thi update từng thư viện một cách an toàn + verification/reviewer loop |
| `/qd-debugging` | "debug after update", "fix runtime error" | Debug all-in-one từ log/build/dev/test với root-cause workflow |

### Điểm khác biệt

- ✅ **Language-agnostic** — hoạt động trên 9 ngôn ngữ lập trình
- ✅ **Confirmation-first** — `/qd-outdated` sinh changelog để user review TRƯỚC khi update
- ✅ **One-by-one** — không bao giờ update nhiều thư viện cùng lúc
- ✅ **Deep analysis** — phân tích breaking changes, CVE, codemod requirements
- ✅ **Rollback ready** — luôn có chiến lược rollback rõ ràng
- ✅ **Debug ready** — có `/qd-debugging` để xử lý lỗi runtime/syntax sau update

---

## Skills

### `/qd-outdated`

Audit toàn bộ dependencies và sinh file `CHANGELOG_DEPENDENCY_UPDATE.md` để review.

**Workflow:**
```
Phase 1: Detect project type (9 ngôn ngữ)
Phase 2: Read dependency manifest
Phase 3: Identify package manager
Phase 4: Run outdated command
Phase 5: search-first research + documentation-lookup (Context7)
Phase 6: Analyze risk + source impact (Critical / Major / Minor / Patch)
Phase 7: Generate CHANGELOG_DEPENDENCY_UPDATE.md
Phase 8: Generate UPDATE-ROADMAP.md (writing-plans style)
```

**Output:**
- `CHANGELOG_DEPENDENCY_UPDATE.md` — changelog chi tiết để user review
- Console summary table với risk classification

**Trigger keywords:**
```
/qd-outdated
check outdated
dependency audit
library versions
which packages need updating
audit dependencies
```

### `/qd-update`

Thực thi update từng thư viện một, dựa trên `CHANGELOG_DEPENDENCY_UPDATE.md` đã được review.

**Workflow:**
```
Phase 1: Audit — đọc CHANGELOG, xác nhận package + version
Phase 2: Classify — confirm risk level
Phase 3: Prepare Baseline — snapshot, test, dedicated branch
Phase 4: Update ONE library
Phase 5: Verification-loop — build, typecheck, lint, test, runtime check
Phase 6: Build-error-resolver loop (if compile/build fail)
Phase 7: Handoff qd-debugging (if runtime/dev syntax fail)
Phase 8: Reviewer pass (typescript/python/go + requesting-code-review)
```

**Confirmation workflow:**
```
/qd-outdated → [User reviews CHANGELOG_DEPENDENCY_UPDATE.md]
     ↓
/qd-update → [Per-library confirmation before each update]
     ↓
[Build → Test → Verify → Commit]
```

### `/qd-debugging`

Debug all-in-one cho mọi lỗi, không chỉ lỗi sau update.

**Workflow:**
```
Phase 1: Intake issue/log file
Phase 2: Evidence collection (stack trace, build/test/dev logs)
Phase 3: Systematic root-cause analysis
Phase 4: Minimal fix + verification-before-completion
Phase 5: Optional TDD regression test
Phase 6: Final debug report + next action
```

**Trigger keywords:**
```
/qd-update react
upgrade package
safe update
update react to
update package
upgrade antd to
```

---

## Quick Start

### Install

**Option 1: Claude Code Plugin Marketplace (Recommended)**

```bash
/plugin marketplace add https://github.com/NguyenThong251/quocduyapp-plugin
/plugin install quocduyapp@quocduyapp
```

**Option 2: Git URL**

```bash
/plugin add https://github.com/NguyenThong251/quocduyapp-plugin
```

**Option 3: Local Clone**

```bash
git clone https://github.com/NguyenThong251/quocduyapp-plugin.git
# Copy vào Claude Code plugins directory
```

### Sử dụng

```bash
# 1. Audit dependencies — sinh changelog để review
/qd-outdated

# 2. Mở file CHANGELOG_DEPENDENCY_UPDATE.md để xem chi tiết
# User review và chỉnh sửa nếu cần

# 3. Thực thi update từng thư viện
/qd-update react
# → Confirm trước khi thực thi
# → Verify sau mỗi update
# → Commit khi pass

/qd-update antd
/qd-update vite
```

---

## Supported Languages

| Ngôn ngữ | Manifest | Package Manager | Outdated Command |
|----------|----------|-----------------|-----------------|
| Node.js / React | `package.json` | yarn | `yarn outdated` |
| Node.js / React | `package.json` | npm | `npm outdated` |
| Node.js / React | `package.json` | pnpm | `pnpm outdated` |
| PHP | `composer.json` | Composer | `composer outdated` |
| Python | `requirements.txt` | pip | `pip list --outdated` |
| Python | `pyproject.toml` | Poetry | `poetry show --outdated` |
| Go | `go.mod` | go | `go list -m -u all` |
| Rust | `Cargo.toml` | cargo | `cargo outdated` |
| Java (Maven) | `pom.xml` | Maven | `mvn versions:display-dependency-updates` |
| Java (Gradle) | `build.gradle` | Gradle | `gradle dependencyUpdates` |
| C# / .NET | `*.csproj` | dotnet | `dotnet list package --outdated` |
| Ruby | `Gemfile` | bundler | `bundle outdated` |
| React Native | `package.json` | yarn/npm | `yarn outdated` |

---

## Risk Classification

| Level | Trigger | Action |
|-------|---------|--------|
| 🔴 **Critical (CVE)** | Security vulnerability detected | Update immediately — không cần debate |
| 🔴 **Major (2+ behind)** | Major version, 2+ versions behind | Incremental migration — không big bang |
| 🟡 **Major (1 behind)** | Major version, 1 version behind | Codemod-assisted migration |
| 🟡 **Minor** | Minor version jump | Test regression trước |
| 🟢 **Patch** | Patch version | Safe to update |

---

## Anti-patterns

- ❌ Không update tất cả library cùng lúc
- ❌ Không ignore major version jumps
- ❌ Không update khi chưa có baseline
- ❌ Không big bang rewrite khi 2+ major behind
- ❌ Không commit khi verify fails

---

## Preventive Tooling

Sau khi update, khuyến nghị setup:

| Tool | Mục đích |
|------|----------|
| **Renovate Bot** | Auto PR khi có version mới |
| **CI: yarn audit** | Security CVE check trong pipeline |
| **CI: lockfile check** | Detect lockfile changes trong PR |
| **Quarterly review** | 3 tháng/lần chạy `/qd-outdated` |

---

## Rollback Strategy

```bash
# Undo single library update
git revert HEAD

# Restore lockfile
git checkout yarn.lock
yarn install

# Version pinning (temporary)
yarn add react@19.2.4 --exact
```

---

## Install Guide — Multiple Platforms

### Claude Code (Official)

```bash
/plugin marketplace add https://github.com/NguyenThong251/quocduyapp-plugin
/plugin install quocduyapp@quocduyapp
```

### Claude Code (Alternative — Git URL)

```bash
/plugin add https://github.com/NguyenThong251/quocduyapp-plugin
```

### Cursor

```text
/add-plugin https://github.com/NguyenThong251/quocduyapp-plugin
```

### Codex / OpenCode

```bash
# Tell your agent:
Fetch and follow instructions from https://raw.githubusercontent.com/NguyenThong251/quocduyapp-plugin/main/README.md
```

---

## Workflow Diagram

```
┌─────────────────────────────────────────────┐
│              /qd-outdated                    │
│  (Audit all deps → Generate changelog)      │
└──────────────────────┬──────────────────────┘
                       │
                       ▼
          CHANGELOG_DEPENDENCY_UPDATE.md
                       │
                       ▼
           [User reviews & edits]
                       │
                       ▼
┌─────────────────────────────────────────────┐
│              /qd-update <package>            │
│  (Per-library confirmation + step-by-step)  │
└──────────────────────┬──────────────────────┘
                       │
         ┌─────────────┴─────────────┐
         ▼                             ▼
   Baseline created              Update ONE library
         │                             │
         ▼                             ▼
   Build + Test + Snap          Verify (build/test/bundle)
         │                             │
         ▼                             ▼
      All pass? ─── No ──→ Rollback
         │
        Yes
         ▼
      Commit + PR
```

---

## Plugin Management

### Update Plugin (Khi có phiên bản mới)

**Cách 1: Tự động update (Recommended)**

```bash
# Trong Claude Code session, chạy:
/plugin update quocduyapp
```

**Cách 2: Manual update qua marketplace**

```bash
# Xóa plugin cũ
/plugin uninstall quocduyapp

# Cài lại từ marketplace
/plugin marketplace add https://github.com/NguyenThong251/quocduyapp-plugin
/plugin install quocduyapp@quocduyapp
```

**Cách 3: Pull code mới nhất từ Git**

```bash
# Clone repo
git clone https://github.com/NguyenThong251/quocduyapp-plugin.git

# Copy thủ công vào plugins directory của Claude Code
# Windows: C:\Users\<user>\.claude\plugins\
# macOS: ~/.claude/plugins/
# Linux: ~/.claude/plugins/
```

### Uninstall Plugin

```bash
# Gỡ plugin
/plugin uninstall quocduyapp

# Hoặc xóa thủ công
# Windows: Xóa thư mục C:\Users\<user>\.claude\plugins\quocduyapp\
# macOS/Linux: rm -rf ~/.claude/plugins/quocduyapp/
```

### Kiểm tra Plugin đã cài đặt

```bash
# Xem danh sách plugins đã cài
/plugin list

# Hoặc xem phiên bản hiện tại
/plugin info quocduyapp
```

### Xem Plugin Source

```bash
# Plugin được cache tại:
# Windows: C:\Users\<user>\.claude\plugins\cache\NguyenThong251\quocduyapp-plugin\
# macOS/Linux: ~/.claude/plugins/cache/NguyenThong251/quocduyapp-plugin/
```

---

## License

MIT — Free to use, modify, and distribute.
