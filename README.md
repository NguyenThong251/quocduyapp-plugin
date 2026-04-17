# QuocDuyApp — Claude Code Plugin

Dependency management và code quality skills cho hệ sinh thái QuocDuyApp.

## Skills

### `/qd-outdated`

Kiểm tra tất cả thư viện outdated trong project, dùng cho bất kỳ ngôn ngữ nào:

```bash
/qd-outdated
```

**Supported:**
- Node.js / React / React Native (yarn, npm, pnpm)
- PHP (Composer)
- Python (pip, Poetry)
- Go (go get)
- Rust (cargo)
- Java (Maven, Gradle)
- C# / .NET (dotnet)
- Ruby (bundler)

**Output:** `DEPENDENCY-REPORT.md` với risk classification

### `/qd-update`

Thực thi update an toàn, từng thư viện một:

```bash
/qd-update react
```

**Pre-requisite:** Chạy `/qd-outdated` trước

**Workflow:**
1. Audit → 2. Classify → 3. Baseline → 4. Update ONE → 5. Verify → 6. Deploy

## Install

```bash
# Clone repo
git clone <repo-url> quocduyapp

# Copy vào Claude plugins folder
cp -r quocduyapp ~/.claude/plugins/

# Restart Claude Code
```

## Quick Start

```bash
# 1. Audit dependencies
/qd-outdated

# 2. Review DEPENDENCY-REPORT.md

# 3. Update từng package một
/qd-update react
/qd-update antd
```

## Rules

- ✅ Language-agnostic
- ✅ One library at a time
- ✅ Always create baseline
- ✅ Always verify before commit

## License

MIT
