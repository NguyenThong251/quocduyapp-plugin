---
name: qd-brain
description: Second brain for Claude Code — persistent context, session memory, learned rules, project documentation. Preserves project understanding across sessions and machines.
triggers:
  - /qd-brain
  - save context
  - remember this
  - learn rules
  - project memory
  - session memory
---

# /qd-brain

**Second Brain.** Persistent context + memory system for Claude Code. Learns project structure, rules, and saves session state so you can continue from anywhere.

---

## Folder Structure

```
.doc/                          # Project brain (gitignored, local only)
├── session/                   # Session memories
│   ├── active/               # Current session context
│   │   └── current.md       # What's being worked on now
│   └── archive/             # Past session summaries
│       ├── YYYY-MM-DD/      # By date
│       └── by-feature/      # Organized by feature
├── plan/                     # Feature plans
│   ├── drafts/              # In-progress plans
│   ├── approved/            # Confirmed plans
│   └── history/             # Completed plans
├── rule/                     # Learned rules
│   ├── git.md              # Git workflow rules
│   ├── style.md            # Code style rules
│   ├── naming.md           # Naming conventions
│   ├── debug.md            # Debug patterns
│   └── custom/             # Project-specific rules
├── agent/                   # Agent configurations
│   └── states/             # Agent state files
└── memory/                  # Persistent memory
    ├── project.md          # Project overview
    ├── structure.md        # Directory structure
    └── features.md         # Feature tracking
```

---

## Step 1 — Initialize Brain (First Run)

### Create Directory Structure

```bash
mkdir -p .doc/{session/{active,archive/{YYYY-MM-DD,by-feature}},plan/{drafts,approved,history},rule/custom,agent/states,memory}
```

### Create Root Memory File

`.doc/memory/project.md`:
```markdown
# Project Brain

## Overview
- **Project**: {project name}
- **Created**: {date}
- **Last Updated**: {date}
- **Tech Stack**: {list}

## Current Focus
- {what's being worked on}

## Key Context
- {important project-specific info}

## Session History
See `session/archive/` for past sessions.
```

### Create Git Rules

`.doc/rule/git.md`:
```markdown
# Git Rules

## Before Push
- [ ] All changes reviewed
- [ ] Tests pass locally
- [ ] No secrets committed
- [ ] Commit message follows convention

## Push Protocol
- **NEVER push without user confirmation** on sensitive branches
- Main/dev branches require explicit approval
- Feature branches can push freely

## Commit Convention
```
<type>: <description>

<optional body>
```
Types: feat, fix, refactor, docs, test, chore, perf, ci

## Branch Naming
- Feature: `feature/<name>`
- Bugfix: `fix/<issue>`
- Update: `update/<package>-<from>-to-<to>`

## Rollback Protocol
```bash
git revert HEAD
git checkout <file>
```
```

### Create Style Rules

`.doc/rule/style.md`:
```markdown
# Code Style Rules

## Naming Conventions
- Variables/functions: camelCase
- Components/Classes: PascalCase
- Constants: UPPER_SNAKE_CASE
- Files: kebab-case or camelCase (per project)

## Best Practices
- Keep functions < 50 lines
- Keep files < 800 lines
- Use meaningful names
- Handle errors explicitly

## Project-Specific
{Learned from /qd-deepinit and code analysis}
```

---

## Step 2 — Session Management

### On Session Start

1. Read `.doc/memory/project.md`
2. Read `.doc/session/active/current.md` (if exists)
3. Read recent session archives to understand context
4. Read active plans from `.doc/plan/drafts/`

### During Session

**Auto-save triggers:**
- After implementing a feature
- After fixing a bug
- After making significant decisions
- Before ending session

**Save to session active:**
```markdown
# Session: {date} {time}

## Tasks Completed
- {task 1}
- {task 2}

## Decisions Made
- {decision 1}
- {decision 2}

## Issues Found
- {issue 1}
- {issue 2}

## Next Steps
- {next action}

## Code Changes
- `file.ts`: {what changed}
```

### On Session End

1. Summarize session into `.doc/session/archive/YYYY-MM-DD/session-N.md`
2. Update `.doc/memory/project.md` if major changes
3. Update `.doc/plan/history/` if plans completed
4. Clear `.doc/session/active/current.md` or mark as complete

---

## Step 3 — Plan Management

### Creating a Plan

When user requests a feature:

1. Create draft: `.doc/plan/drafts/feature-name.md`
```markdown
# Plan: {Feature Name}

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

## Status
- [x] Drafted
- [ ] Approved
- [ ] In Progress
- [ ] Completed

## Agent Handoff
{Detailed instructions for another agent to pick up}
```

2. Present to user for approval
3. Move to `approved/` when confirmed
4. Move to `history/` when completed

### Agent Handoff Format

```markdown
## Agent Handoff

You are implementing: {feature name}

Context:
- Project: {name}
- Tech stack: {stack}
- Existing patterns: {patterns}

Your task:
{detailed task description}

Files to modify:
{list}

Steps to follow:
1. {step}
2. {step}

Rules:
- {rule 1}
- {rule 2}

Verification:
- {how to verify it works}
```

---

## Step 4 — Rule Learning

### From Git History

Analyze recent commits to learn patterns:

```bash
git log --oneline -20
git diff HEAD~5 --name-only
```

Extract:
- Commit message style
- File change patterns
- Branch naming conventions

### From Code Analysis

Analyze existing code to learn:

- Naming conventions (check file names, function names)
- Code organization (folder structure)
- Patterns used (observers, handlers, etc.)
- Error handling style
- Documentation style

### From /qd-deepinit

If AGENTS.md exists:
- Read all AGENTS.md files
- Extract directory purposes
- Learn AI agent instructions

### Rule Categories to Learn

1. **Git Rules**: Workflow, commit style, branch names
2. **Code Style**: Naming, formatting, best practices
3. **Debug Rules**: Common issues, fix patterns
4. **Naming Rules**: File naming, variable naming
5. **Refactor Rules**: When to refactor, patterns to follow

---

## Step 5 — Context Preservation

### Cross-Session Continuity

When continuing work after break:

1. Read `.doc/memory/project.md`
2. Read `.doc/session/archive/by-feature/{feature}.md`
3. Check `.doc/plan/approved/` for active plans
4. Ask user: "Continuing from previous session. Last work was on {feature}. Continue?"

### Cross-Machine Continuity

When opening project on different machine:

1. Sync `.doc/` via git (add to git if not already)
2. Or manually copy `.doc/` folder
3. Claude Code reads `.doc/memory/` first
4. Understands full context immediately

---

## Step 6 — Learn from /qd-deepinit

### Read Existing AGENTS.md

If project has AGENTS.md files:

1. Read root `AGENTS.md`
2. Read relevant subdirectory AGENTS.md
3. Extract directory purposes into `.doc/memory/structure.md`

### Generate Structure Doc

`.doc/memory/structure.md`:
```markdown
# Project Structure

## Root
- `src/`: {purpose}
- `docs/`: {purpose}
- `tests/`: {purpose}

## Key Directories
| Directory | Purpose | AGENTS |
|---------|---------|--------|
| `src/` | Source code | See `src/AGENTS.md` |
| `src/components/` | React components | See `src/components/AGENTS.md` |
```

---

## Step 7 — Auto-Save During Session

### Save Points

After each significant action:

1. **Feature implemented** → Update session + plan
2. **Bug fixed** → Document fix pattern
3. **Decision made** → Save to decisions log
4. **Rule discovered** → Save to appropriate rule file

### Quick Save Command

```
// In conversation
"Save this" → Summarize + save to active session

"Remember rule: {rule}" → Save to .doc/rule/custom/

"Update plan: {changes}" → Update draft plan
```

---

## Step 8 — Initialize from /qd-deepinit

Run `/qd-deepinit` first, then:

1. Read all generated AGENTS.md files
2. Convert to `.doc/memory/structure.md`
3. Extract AI agent instructions to `.doc/rule/custom/`
4. Create project overview in `.doc/memory/project.md`

---

## Usage Examples

### First Time Setup
```
User: /qd-brain init
Claude: Initializing project brain...
- Creating folder structure
- Creating memory files
- Creating git rules
- Creating style rules
Done. Run /qd-deepinit to learn project structure.
```

### Save Session
```
User: save session
Claude: Saving session...
- Summarizing tasks completed
- Saving decisions
- Archiving to .doc/session/archive/
Done.
```

### Continue Work
```
User: continue the auth feature
Claude: Reading context from .doc/...
- Found active plan: auth-feature.md
- Last session: implemented login
- Next: implement logout
Ready to continue.
```

### Learn New Rule
```
User: remember: always validate input at system boundaries
Claude: Saved to .doc/rule/custom/validation.md
```

---

## Commands

| Command | Action |
|---------|--------|
| `/qd-brain init` | Initialize brain structure |
| `/qd-brain save` | Save current session |
| `/qd-brain load` | Load session context |
| `/qd-brain learn` | Learn rules from code/git |
| `/qd-brain plan <name>` | Create new plan |
| `/qd-brain status` | Show brain status |

---

## Files to GitIgnore

Add to `.gitignore`:
```gitignore
.doc/session/active/
.doc/agent/states/
```

Keep in git:
```gitignore
!.doc/session/archive/
!.doc/plan/
!.doc/rule/
!.doc/memory/
```

---

## Source

Combines patterns from `/qd-deepinit` and session management best practices.
