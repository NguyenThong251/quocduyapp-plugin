---
name: qd-brain
description: Second brain for Claude Code — persistent context, session memory, project documentation, AGENTS.md generation, learned rules. Preserves project understanding across sessions and machines.
triggers:
  - /qd-brain
  - save context
  - remember this
  - learn rules
  - project memory
  - session memory
  - create AGENTS.md
  - generate project docs
---

# /qd-brain

**Second Brain.** Persistent context + memory + documentation system for Claude Code. Learns project structure, generates AGENTS.md, saves session state, and preserves context across sessions and machines.

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
    ├── structure.md        # Directory structure (from AGENTS.md)
    └── features.md         # Feature tracking
```

---

## Commands

| Command | Action |
|---------|--------|
| `/qd-brain init` | Initialize brain structure |
| `/qd-brain learn` | Learn project structure, rules, patterns |
| `/qd-brain save` | Save current session |
| `/qd-brain load` | Load session context |
| `/qd-brain plan <name>` | Create new plan |
| `/qd-brain status` | Show brain status |
| `/qd-brain docs` | Generate/update AGENTS.md files |

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
{Learned from code analysis - see .doc/memory/structure.md}
```

---

## Step 2 — Learn Project Structure (Auto-learn)

Run this after init or when starting on new project.

### Map Directory Structure

Use Explore agent or glob to list all directories:

```bash
find . -type d ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' ! -path '*/build/*' ! -path '*/__pycache__/*' ! -path '*/.venv/*' ! -path '*/coverage/*' ! -path '*/.next/*' ! -path '*/.nuxt/*' ! -path '*/.doc/*' | sort
```

### Analyze Each Directory

For each directory, read key files to understand:
- What the directory contains
- How components relate
- Special instructions needed
- Dependencies

### Generate Structure Doc

`.doc/memory/structure.md`:
```markdown
# Project Structure

## Directory Tree
```
{output from find command}
```

## Key Directories
| Directory | Purpose |
|-----------|---------|
| `src/` | {purpose} |
| `src/components/` | {purpose} |

## Learned Patterns
{Learned from analyzing existing code}
```

---

## Step 3 — Generate AGENTS.md Files

**Core Concept:** AGENTS.md files serve as **AI-readable documentation** that helps agents understand the codebase.

### Hierarchical Tagging System

Every AGENTS.md (except root) includes a parent reference tag:

```markdown
<!-- Parent: ../AGENTS.md -->
```

Creates a navigable hierarchy:
```
/AGENTS.md                          ← Root (no parent tag)
├── src/AGENTS.md                   ← <!-- Parent: ../AGENTS.md -->
│   ├── src/components/AGENTS.md   ← <!-- Parent: ../AGENTS.md -->
│   └── src/utils/AGENTS.md       ← <!-- Parent: ../AGENTS.md -->
└── docs/AGENTS.md                 ← <!-- Parent: ../AGENTS.md -->
```

### AGENTS.md Template

```markdown
<!-- Parent: {relative_path_to_parent}/AGENTS.md -->
<!-- Generated: {timestamp} | Updated: {timestamp} -->

# {Directory Name}

## Purpose
{One-paragraph description of what this directory contains and its role}

## Key Files
{List each significant file with a one-line description}

| File | Description |
|------|-------------|
| `file.ts` | Brief description of purpose |

## Subdirectories
{List each subdirectory with brief purpose}

| Directory | Purpose |
|-----------|---------|
| `subdir/` | What it contains (see `subdir/AGENTS.md`) |

## For AI Agents

### Working In This Directory
{Special instructions for AI agents modifying files here}

### Testing Requirements
{How to test changes in this directory}

### Common Patterns
{Code patterns or conventions used here}

## Dependencies

### Internal
{References to other parts of the codebase this depends on}

### External
{Key external packages/libraries used}

<!-- MANUAL: Any manually added notes below this line are preserved on regeneration -->
```

### AGENTS.md Generation Workflow

1. **Map directories** (Step 2 above)
2. **Organize by depth level**:
   ```
   Level 0: / (root)
   Level 1: /src, /docs, /tests
   Level 2: /src/components, /src/utils
   ...
   ```
3. **Generate parent levels first** (ensures parent references are valid)
4. **For each directory:**
   - Read key files
   - Analyze purpose and relationships
   - Generate AGENTS.md content
   - Write with proper parent reference

### Update Mode (if AGENTS.md exists)

When AGENTS.md already exists:

1. **Read existing content**
2. **Identify sections:**
   - Auto-generated sections (can be updated)
   - Manual sections (`<!-- MANUAL -->` preserved)
3. **Compare:**
   - New files added?
   - Files removed?
   - Structure changed?
4. **Merge:**
   - Update auto-generated content
   - Preserve manual annotations
   - Update timestamp

### Validate Hierarchy

After generation, verify:

| Check | How to Verify | Corrective Action |
|-------|--------------|-------------------|
| Parent references resolve | Read each AGENTS.md, check `<!-- Parent: -->` path exists | Fix path or remove orphan |
| No orphaned AGENTS.md | Compare locations to directory structure | Delete orphaned files |
| Completeness | List directories, check for AGENTS.md | Generate missing files |

### Empty Directory Handling

| Condition | Action |
|-----------|--------|
| No files, no subdirectories | **Skip** - do not create AGENTS.md |
| No files, has subdirectories | Create minimal AGENTS.md with subdirectory listing only |
| Has only generated files (*.min.js, *.map) | Skip or minimal AGENTS.md |
| Has only config files | Create AGENTS.md describing configuration purpose |

### Parallelization

1. **Same-level directories**: Process in parallel
2. **Different levels**: Sequential (parent first)
3. **Large directories**: Spawn dedicated agent per directory
4. **Small directories**: Batch multiple into one agent

---

## Step 4 — Learn Rules from Code

### From Git History

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
- Naming conventions (file names, function names)
- Code organization (folder structure)
- Patterns used (observers, handlers, etc.)
- Error handling style
- Documentation style

### Update Rule Files

After learning, update:
- `.doc/rule/style.md` - code style patterns
- `.doc/rule/naming.md` - naming conventions
- `.doc/rule/git.md` - git workflow (if different)

---

## Step 5 — Session Management

### On Session Start

1. Read `.doc/memory/project.md`
2. Read `.doc/session/active/current.md` (if exists)
3. Read recent session archives to understand context
4. Read active plans from `.doc/plan/drafts/`
5. Ask: "Continuing from previous session. Last work was on {feature}. Continue?"

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

## Step 6 — Plan Management

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

## Step 7 — Context Preservation

### Cross-Session Continuity

When continuing work after break:

1. Read `.doc/memory/project.md`
2. Read `.doc/session/archive/by-feature/{feature}.md`
3. Check `.doc/plan/approved/` for active plans
4. Ask user to confirm and continue

### Cross-Machine Continuity

When opening project on different machine:

1. Sync `.doc/` via git (add to git if not already)
2. Or manually copy `.doc/` folder
3. Claude Code reads `.doc/memory/` first
4. Understands full context immediately

---

## Step 8 — Auto-Save During Session

### Save Points

After each significant action:

1. **Feature implemented** → Update session + plan
2. **Bug fixed** → Document fix pattern
3. **Decision made** → Save to decisions log
4. **Rule discovered** → Save to appropriate rule file

### Quick Save Commands

```
"Save this" → Summarize + save to active session

"Remember rule: {rule}" → Save to .doc/rule/custom/

"Update plan: {changes}" → Update draft plan
```

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
Done. Run /qd-brain learn to analyze project structure.
```

### Learn Project
```
User: /qd-brain learn
Claude: Learning project structure...
- Mapping directories
- Analyzing code patterns
- Extracting conventions
- Generating AGENTS.md files
Done. Project brain initialized.
```

### Generate Documentation
```
User: /qd-brain docs
Claude: Generating AGENTS.md files...
- Creating root AGENTS.md
- Creating src/AGENTS.md
- Creating src/components/AGENTS.md
Done. Documentation generated.
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
User: remember rule: always validate input at system boundaries
Claude: Saved to .doc/rule/custom/validation.md
```

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

Combines hierarchical documentation (AGENTS.md), session memory, plan management, and rule learning into a unified second brain system.
