---
name: qd-xia
description: Learn skill from external repo (oh-my-claudecode, Claude Code marketplace) and adapt/clone/combine into qd- namespace skill. Usage: qd-xia <source-skill> or qd-xia <source-skill> + <another-skill>
triggers:
  - /qd-xia
  - learn from
  - adapt skill
  - clone skill
  - combine skills
  - fork skill
---

# /qd-xia

**Learn & Adapt.** Fetch a skill from external repo (oh-my-claudecode, marketplace) or combine multiple skills, then generate a new `qd-` namespaced skill.

---

## Step 1 — Parse Intent

User input co the la:

| Input | Meaning |
|-------|---------|
| `/qd-xia deepinit` | Clone `deepinit` skill into `qd-deepinit` |
| `/qd-xia /deepinit` | Clone `deepinit` skill into `qd-deepinit` |
| `/qd-xia /deepinit + /init` | Combine `deepinit` + `init` into one skill |
| `/qd-xia deepinit + init` | Combine `deepinit` + `init` into one skill |

Neu nhiều skill quá khó kết hợp -> đưa ra options cho user chọn.

**Suggested naming:**
- Clone: `qd-<original-name>` (lowercase)
- Combine: user tự đặt hoặc gợi ý + confirm

## Step 2 — Fetch Full Source Skill(s)

**CRITICAL: Clone the ENTIRE skill file, not a summary.**

Fetch ALL content of the source skill, including:
- Frontmatter (name, description, triggers)
- ALL sections (Steps, Patterns, Rules, Examples, etc.)
- Complete content in every section
- Exact formatting and structure

### Parse Source Input

User can provide skill from ANY source:

| User input | Source | Example |
|-------------|--------|---------|
| `/qd-xia deepinit` | oh-my-claudecode repo (default) | Default repo |
| `/qd-xia owner/repo skill-name` | Any GitHub repo | `user/another-plugin deep-dive` |
| `/qd-xia https://github.com/...` | Direct GitHub URL | Full path |
| `/qd-xia local skill-name` | Local Claude Code skills | `~/.claude/skills/` |
| `/qd-xia marketplace skill-name` | Already installed marketplace skill | Check local first |

If user provides only skill name without repo -> try oh-my-claudecode repo first, then local installation.

### From GitHub repo (generic)

```bash
# List available skills in a repo
gh api repos/<owner>/<repo>/contents/<path-to-skills> \
  --jq '.[].name'

# Fetch COMPLETE skill content (all lines)
gh api repos/<owner>/<repo>/contents/<path-to-skills>/<skill-name>/SKILL.md \
  --jq '.content' | base64 -d

# Alternative: clone entire repo then read locally
git clone https://github.com/<owner>/<repo>.git /tmp/skill-source
cat /tmp/skill-source/<path-to-skills>/<skill-name>/SKILL.md
```

### From local Claude Code installation

```bash
# List installed skills (check multiple locations)
ls ~/.claude/skills/
ls ~/.claude/plugins/*/skills/ 2>/dev/null || true

# Read COMPLETE skill content
cat ~/.claude/skills/<skill-name>/SKILL.md
```

### From marketplace (already installed)

Some skills are already installed in Claude Code. Check:

```bash
# List all skills in common locations
ls ~/.claude/skills/
find ~/.claude -name "SKILL.md" 2>/dev/null | head -20

# Read if found
cat ~/.claude/<path-to-skill>/SKILL.md
```

### Check for additional skill files

Some skills may have extra files besides SKILL.md:

```bash
# List all files in skill directory
gh api repos/<owner>/<repo>/contents/<path-to-skills>/<skill-name> \
  --jq '.[].name'

# Or locally
ls ~/.claude/skills/<skill-name>/

# Fetch sub-files if any
gh api repos/<owner>/<repo>/contents/<path-to-skills>/<skill-name>/<file> \
  --jq '.content' | base64 -d
```

Fetch ALL related files to ensure complete clone.

## Step 3 — Preserve Full Structure

**CRITICAL: Keep the ENTIRE original structure intact.**

When analyzing:
- Preserve ALL sections from source skill
- Preserve ALL content within each section (no summarizing/cutting)
- Preserve exact formatting, code blocks, tables, examples
- Preserve the logical flow and order of steps

Do NOT:
- Summarize or shorten content
- Remove examples or edge cases
- Skip sections that seem redundant
- Condense multi-line explanations

The goal is a TRUE clone with qd- namespace, not a summary.

## Step 4 — Propose Skill Spec

### Clone Case

Neu chi 1 skill:
- Giữ nguyên logic + steps
- Doi trigger: `/deepinit` -> `/qd-deepinit`
- Add QuocDuyApp conventions: safe update, verification, rollback
- Ten skill: `qd-<original>`

### Combine Case

Neu 2+ skill:
- Tim **overlap** (cac buoc trung nhau)
- Tim **complementary** (buoc nay bo sung buoc kia)
- Merge steps theo thu tu hop ly
- Conflict handling: hoi user hoac chon conservative option
- Suggested name: propose 2-3 options

### Name Recommendation Format

```
Suggested name(s):
1. qd-<feature>        — if one skill
2. qd-<merged-feature> — if combined

Trigger: /qd-<feature>

Ready to create? [y/n]
```

## Step 5 — Create Skill (Full Clone)

**CRITICAL: Write the COMPLETE source skill content, not a condensed version.**

After user confirms name:

1. Create directory: `skills/qd-<name>/`
2. Create `SKILL.md` with frontmatter:
```markdown
---
name: qd-<name>
description: <original description, adapted for qd- namespace>
triggers:
  - /qd-<name>
  - <key phrases from source>
---
```

3. **Write the COMPLETE skill content:**
   - Copy ALL sections from source (verbatim where applicable)
   - Copy ALL content within each section (do not summarize)
   - Copy ALL examples, code blocks, tables
   - Preserve exact structure and order
   - Adapt ONLY: trigger names (`/source` -> `/qd-source`), frontmatter `name` field

### What to ADAPT (minimal changes):
- `name:` in frontmatter -> `qd-<original>`
- Trigger values -> `/qd-<name>`
- Any internal references to the original trigger

### What to KEEP (full content):
- ALL steps and their complete descriptions
- ALL examples and edge cases
- ALL patterns, rules, conventions
- ALL code blocks and their full content
- ALL tables and their complete data
- ALL formatting and structure

### QuocDuyApp Conventions to ADD (optional):
- Verification step after actions (if not present)
- Error handling mention (if not present)
- Report output format at end (if not present)
- Reference to memory/project context (if relevant)

## Step 6 — Validate Skill

Check:
- [ ] Frontmatter co `name`, `description`, `triggers`
- [ ] Trigger duy nhat (khong trung voi skill hien co)
- [ ] Content duoc format dung
- [ ] Khong trung lap logic voi skill cu
- [ ] **ALL sections from source are present**
- [ ] **ALL content from source is preserved (no summarization)**
- [ ] **All examples, code blocks, tables are intact**

## Step 7 — Report

```
Created: skills/qd-<name>/SKILL.md
Triggers: /qd-<name>
Source: <original skill(s)>
Adaptations:
  - <changes made>
  - <added conventions>
  - <removed/redacted parts>

Usage: /qd-<name> [args]
```

## Examples

### Example 1: Clone single skill

User: `/qd-xia deepinit`

```
Fetching deepinit from oh-my-claudecode...
Found: deep-init skill (project initialization)

Suggested name: qd-deepinit
Trigger: /qd-deepinit

Ready to create? [y/n]
> y

Created: skills/qd-deepinit/SKILL.md
```

### Example 2: Combine two skills

User: `/qd-xia deepinit + init`

```
Fetching deepinit + init...
deepinit: deep project context gathering
init: new project scaffolding

Found 2 complementary skills.

Suggested names:
1. qd-init-deep   — init first, then deep context
2. qd-deepinit    — deep context, then init (recommended)

Ready to create? [y/n]
> y

Created: skills/qd-deepinit/SKILL.md
```

### Example 3: Too complex

User: `/qd-xia deepinit + init + autopilot + brainstorm`

```
That's 4 skills to combine. Recommended approach:

1. qd-deepinit   — deepinit + init (recommended)
2. qd-autopilot  — autopilot standalone
3. qd-deepinit-full — deepinit + init + autopilot (only if confirmed)

Which would you like? [1/2/3]
```

## Rules

- **CLONE FULL CONTENT.** Copy the entire source skill, not a summary. Every section, every example, every code block must be preserved.
- Chi fetch skill public/authorized. Khong fetch proprietary/paid skills.
- Ghi ro nguon goc trong skill description.
- Khong danh cap credential, API key, hay secret.
- Khong tao skill trung ten voi skill hien co.
- Confirm name voi user truoc khi tao file.
- If unsure about structure, fetch MORE content rather than less.
