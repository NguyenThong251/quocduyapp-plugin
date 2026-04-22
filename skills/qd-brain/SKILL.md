---
name: qd-brain
description: Second brain for Claude Code — persistent context, session memory, project documentation, AGENTS.md generation, learned rules, git history analysis. Preserves project understanding across sessions and machines.
triggers:
  - /qd-brain
  - save context
  - remember this
  - learn rules
  - project memory
  - session memory
  - create AGENTS.md
  - generate project docs
  - analyze patterns
---

# /qd-brain

**Second Brain.** Persistent context + memory + documentation + pattern analysis system for Claude Code. Learns project structure, analyzes git history, generates AGENTS.md, saves session state, and preserves context across sessions and machines.

---

## Folder Structure

```
.doc/                          # Project brain
├── CLAUDE.md                 # Root brain file (read on startup)
├── session/
│   ├── current.md            # Live session tracking
│   ├── handoff.md           # Handoff notes for next session
│   └── history/             # Past session archives
│       └── YYYY-MM-DD_HH-MM.md
├── plan/
│   ├── drafts/              # In-progress plans
│   ├── approved/            # Confirmed plans
│   └── completed/           # Completed plans
├── rules/
│   ├── git.md              # Git workflow rules
│   ├── naming.md           # Naming conventions
│   ├── code-style.md       # Code style rules
│   └── custom/             # Project-specific rules
├── knowledge/
│   ├── architecture.md     # System architecture
│   ├── features/           # Feature documentation
│   │   └── <feature>.md
│   └── issues/             # Known issues
│       └── <id>.md
├── init/
│   └── project-snapshot.md # Project package/dependency snapshot
└── scripts/
    ├── setup-brain.sh       # Verify .doc/ structure
    ├── save-session.sh       # Quick save to current session
    └── archive-session.sh    # Archive session + reset
```

---

## Commands

| Command | Action |
|---------|--------|
| `/qd-brain init` | Initialize brain structure |
| `/qd-brain learn` | Learn project structure + analyze git history |
| `/qd-brain analyze` | Analyze git history for patterns |
| `/qd-brain docs` | Generate/update AGENTS.md files |
| `/qd-brain save` | Save current session (quick) |
| `/qd-brain load` | Load session context |
| `/qd-brain plan <name>` | Create new plan |
| `/qd-brain status` | Show brain status |
| `/qd-brain handoff` | Create handoff notes |

---

## Step 1 — Initialize Brain (First Run)

### Create Directory Structure

```bash
mkdir -p .doc/{session/history,plan/{drafts,approved,completed},rules/custom,knowledge/{features,issues},init,scripts}
```

### Run Setup Script

```bash
# Verify/create .doc/ structure
./.doc/scripts/setup-brain.sh
```

### Create Root Brain File

`.doc/CLAUDE.md`:
```markdown
# Project Brain

**Last Updated**: {date}

## Quick Start
1. Read `session/current.md` — current session context
2. Read `session/handoff.md` — if continuing previous work
3. Read `rules/` — project conventions

## Current Work
{one-line summary of what's being done}

## Active Plans
See `plan/drafts/` and `plan/approved/`

## Session History
See `session/history/`
```

### Create Git Rules (from default-rules.md)

`.doc/rules/git.md`:
```markdown
# Git Rules

## ⚠️ QUAN TRỌNG NHẤT

**KHÔNG BAO GIỜ tự ý git push** — dù là push lên branch của mình.
Luôn phải hỏi và được xác nhận từ người điều khiển trước.

## Commit Convention

Format: `type(scope): mô tả ngắn gọn`

Types:
- `feat`: tính năng mới
- `fix`: sửa bug
- `refactor`: cải thiện code không thêm feature/fix bug
- `docs`: chỉ thay đổi tài liệu
- `test`: thêm/sửa test
- `chore`: build system, dependencies
- `hotfix`: fix khẩn cấp trên production

## Branch Naming
- Feature: `feature/<tên-ngắn-gọn>`
- Bug fix: `fix/<issue-id-hoặc-mô-tả>`
- Hotfix: `hotfix/<mô-tả>`
- Release: `release/<version>`

## Hotfix Process
1. Tạo branch `hotfix/<mô-tả>`
2. Fix + test
3. Commit với prefix `hotfix:`
4. Báo cáo người điều khiển để confirm push
5. Merge sau khi được phép

## Rollback Protocol
```bash
git revert HEAD
git checkout <file>
```
```

### Create Session Files

`.doc/session/current.md`:
```markdown
# Session — {YYYY-MM-DD HH:MM}

## Mục tiêu session này

{mục tiêu}

## Đã làm

- {HH:MM} {action}

## Quyết định quan trọng

- {decision}: {lý do}

## Issues phát hiện

- {issue}: {status}

## Rules mới

- {rule}: {context}

## TODO cuối session

- [ ] {item}
```

`.doc/session/handoff.md`:
```markdown
# Handoff Notes

**Last Updated**: {date}

## Đang làm gì
{one-line summary}

## Còn dang dở
- {item}

## Bước tiếp theo
1. {step}

## Cần lưu ý
- {note}

## Risk/Blocker
- {risk}
```

---

## Step 2 — Analyze Git History (Extract Patterns)

Use `/qd-brain analyze` to learn project conventions from git history.

### Gather Git Data

```bash
# Get recent commits with file changes
git log --oneline -n ${COMMITS:-200} --name-only --pretty=format:"%H|%s|%ad" --date=short

# Get commit frequency by file
git log --oneline -n 200 --name-only | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | head -20

# Get commit message patterns
git log --oneline -n 200 | cut -d' ' -f2- | head -50
```

### Detect Pattern Types

| Pattern | Detection Method |
|---------|-----------------|
| **Commit conventions** | Regex on commit messages (feat:, fix:, chore:) |
| **File co-changes** | Files that always change together |
| **Workflow sequences** | Repeated file change patterns |
| **Architecture** | Folder structure and naming conventions |
| **Testing patterns** | Test file locations, naming, coverage |

### Extract Patterns

#### Commit Convention Detection
- Check if commits follow `type(scope): description`
- Extract common types used
- Identify scope patterns

#### File Co-change Detection
- Files that always appear together in commits
- Common change pairs (e.g., Component + its test)

#### Workflow Sequence Detection
- Repeated patterns of file changes
- Build → Test → Deploy workflows

### Update Rule Files

After analysis, update:
- `.doc/rules/git.md` — commit conventions
- `.doc/rules/naming.md` — file naming patterns
- `.doc/rules/code-style.md` — code patterns

---

## Step 3 — Learn Project Structure

### Map Directory Structure

```bash
find . -type d ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' ! -path '*/build/*' ! -path '*/__pycache__/*' ! -path '*/.venv/*' ! -path '*/coverage/*' ! -path '*/.next/*' ! -path '*/.nuxt/*' ! -path '*/.doc/*' | sort
```

### Analyze Each Directory

For each directory:
1. Read key files to understand purpose
2. Identify relationships with other directories
3. Note special instructions for AI agents
4. Document dependencies

### Generate Architecture Doc

`.doc/knowledge/architecture.md`:
```markdown
# Architecture — {Project Name}

**Last updated**: {date}

## Overview
{mô tả tổng quan hệ thống}

## Cấu trúc thư mục
```
{tree output}
```

## Data Flow
{mô tả data đi qua hệ thống như thế nào}

## Entry Points
- `<file>`: <mục đích>

## Module chính
| Module | Vị trí | Chức năng |
|--------|---------|-----------|
| {name} | {path}  | {purpose} |

## Patterns đang dùng
- {pattern}: {mô tả}

## Known constraints
- {constraint}: {lý do}
```

### Generate Project Snapshot

`.doc/init/project-snapshot.md`:
```markdown
# Project Snapshot — {date}

## Package info
{tên, version, author từ package.json/Cargo.toml/pyproject.toml}

## Dependencies chính
| Package | Version | Mục đích |
| ------- | ------- | -------- |
| {name}  | {ver}   | {why}    |

## Scripts
| Script | Lệnh  | Mục đích |
| ------ | ----- | -------- |
| {name} | {cmd} | {why}    |

## Environment variables cần thiết
- `<VAR_NAME>`: {mô tả}

## Cách chạy local
```bash
{commands}
```

## Cách deploy
{steps}
```

---

## Step 4 — Generate AGENTS.md Files

### Hierarchical Tagging System

Every AGENTS.md (except root) includes a parent reference tag:
```markdown
<!-- Parent: ../AGENTS.md -->
```

### AGENTS.md Template

```markdown
<!-- Parent: {relative_path_to_parent}/AGENTS.md -->
<!-- Generated: {timestamp} | Updated: {timestamp} -->

# {Directory Name}

## Purpose
{One-paragraph description}

## Key Files
| File | Description |
|------|-------------|
| `file.ts` | Brief description |

## Subdirectories
| Directory | Purpose |
|-----------|---------|
| `subdir/` | What it contains (see `subdir/AGENTS.md`) |

## For AI Agents
{Special instructions for AI agents}

### Testing Requirements
{How to test changes here}

### Common Patterns
{Code patterns used here}

## Dependencies
### Internal: {references}
### External: {packages}

<!-- MANUAL: preserved on regeneration -->
```

### Generation Workflow

1. Map directories by depth level
2. Generate parent levels first
3. For each directory: read → analyze → generate → write
4. Validate parent references

### Update Mode (if exists)

1. Read existing content
2. Preserve `<!-- MANUAL -->` sections
3. Update auto-generated sections
4. Update timestamp

---

## Step 5 — Session Management

### Session Format (from session-format.md)

**Compact first** — agent mới đọc trong < 2 phút hiểu được context.

**Lưu WHAT và WHY, không lưu HOW chi tiết:**
- ✅ "Dùng Redis cho session vì latency thấp hơn"
- ❌ "Cài redis bằng npm install ioredis..."

### Archive Format

`.doc/session/history/YYYY-MM-DD_HH-MM.md`:
```markdown
# Session {YYYY-MM-DD HH:MM} → {HH:MM}

**Focus**: {một dòng mô tả}

## Accomplished
- {item}

## Decisions Made
| Quyết định | Lý do | Alternatives đã loại |
| ---------- | ----- | -------------------- |
| {decision} | {why} | {rejected options}   |

## Issues Found
| Issue | Severity | Status |
| ----- | -------- | ------ |
| {issue} | HIGH | RESOLVED |

## New Rules/Patterns
- {rule}: {context}

## Files Changed
- `<path>`: {thay đổi}

## Blockers / Open Questions
- {item}

## Summary
{tóm tắt ngắn nhất}
```

### Handoff Quality Checklist

A good handoff answers:
- [ ] Agent mới đang ở bước nào?
- [ ] Việc gì đang còn dang dở?
- [ ] Có risk hoặc blocker nào không?
- [ ] Bước tiếp theo là gì cụ thể?
- [ ] Có context đặc biệt nào cần biết không?

### On Session Start

1. Read `.doc/CLAUDE.md`
2. Read `.doc/session/handoff.md`
3. Read `.doc/session/current.md` (if unfinished work)
4. Read `.doc/rules/` (all files)
5. Ask: "Tôi đã đọc context. [Summary 2-3 dòng]. Bạn muốn tiếp tục từ đâu?"

### On Session End

1. Read `session/current.md`
2. Extract: accomplished, decisions, issues, new rules, files changed
3. Create `session/history/YYYY-MM-DD_HH-MM.md`
4. Update `session/handoff.md`
5. Reset `session/current.md`
6. Update `.doc/CLAUDE.md` line "Last Updated"

---

## Step 6 — Plan Management

### Create Plan

When user requests a feature:

`.doc/plan/drafts/<feature>.md`:
```markdown
# Plan: {Feature Name}

**Status**: DRAFT | APPROVED | IN_PROGRESS | COMPLETED
**Created**: {date}

## Overview
{Brief description}

## Requirements
- {requirement 1}
- {requirement 2}

## Implementation Steps
1. {step 1}
2. {step 2}
3. {step 3}

## Files to Modify
- `src/file1.ts`
- `src/file2.ts`

## Estimated Effort
{time estimate}

## Agent Handoff
You are implementing: {feature name}

Context:
- Project: {name}
- Tech stack: {stack}
- Existing patterns: {patterns}

Your task: {detailed description}
Steps: 1. {step} 2. {step}
Rules: {rule 1}, {rule 2}
Verification: {how to verify}
```

### Plan Flow
1. Create in `drafts/` → present to user
2. Move to `approved/` when confirmed
3. Move to `completed/` when done

---

## Step 7 — Quick Scripts

### save-session.sh

```bash
# Usage: ./.doc/scripts/save-session.sh "Title" "Content"
```

Quick save to current session without opening file.

### archive-session.sh

Archives current session and creates handoff.

### setup-brain.sh

Verifies/creates `.doc/` structure.

---

## Step 8 — Auto-Save Triggers

After each significant action:

1. **Feature implemented** → Update session + mark plan in progress
2. **Bug fixed** → Document in `knowledge/issues/`
3. **Decision made** → Save to decisions in session
4. **Rule discovered** → Save to `rules/custom/`
5. **New issue found** → Create in `knowledge/issues/`

---

## Usage Examples

### Init Brain
```
User: /qd-brain init
Claude: Initializing brain...
- Creating .doc/ structure
- Creating session files
- Creating rules templates
Done.
```

### Analyze Patterns
```
User: /qd-brain analyze
Claude: Analyzing git history...
- Extracting commit patterns
- Detecting file co-changes
- Learning naming conventions
Found: 150 commits, 80% follow conventional commits
Updated: rules/git.md, rules/naming.md
```

### Learn Structure
```
User: /qd-brain learn
Claude: Learning project...
- Mapping directories
- Analyzing code
- Generating architecture.md
- Creating AGENTS.md files
Done.
```

### Save Quick
```
User: save
Claude: Saving...
✅ Saved decision: "Use Redis for cache"
```

### Continue Work
```
User: continue
Claude: Reading context...
- Last work: implementing auth
- Next: add refresh token
Ready to continue? [y/n]
```

---

## Files to GitIgnore

```gitignore
# Keep in git
!.doc/session/history/
!.doc/plan/
!.doc/rules/
!.doc/knowledge/
!.doc/init/

# Local only (don't commit)
.doc/session/current.md
.doc/session/handoff.md
```

---

## Source

Combines:
- `/skill-create` git history analysis patterns
- `references/default-rules.md` git conventions
- `references/init-templates.md` document templates
- `references/session-format.md` session management
- AGENTS.md generation from hierarchical documentation
