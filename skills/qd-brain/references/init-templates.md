# Init Templates — QD-Brain

## `knowledge/architecture.md` Template

```markdown
# Architecture — <Project Name>

**Last updated**: <date>

## Overview

<mô tả tổng quan hệ thống>

## Cấu trúc thư mục
```

<tree output của dự án>

```

## Data Flow
<mô tả data đi qua hệ thống như thế nào>

## Entry Points
- `<file>`: <mục đích>

## Module chính
| Module | Vị trí | Chức năng |
|--------|---------|-----------|
| <name> | <path>  | <purpose> |

## Patterns đang dùng
- <pattern 1>: <mô tả>
- <pattern 2>: <mô tả>

## Known constraints
- <constraint>: <lý do>
```

---

## `session/current.md` Template

```markdown
# Session — <YYYY-MM-DD HH:MM>

## Mục tiêu session này

<mục tiêu>

## Đã làm

- <HH:MM> <action>
- <HH:MM> <action>

## Quyết định quan trọng

- <decision>: <lý do>

## Issues phát hiện

- <issue>: <status>

## Rules mới

- <rule>: <context>

## TODO cuối session

- [ ] <item>
```

---

## `knowledge/features/<feature>.md` Template

```markdown
# Feature: <name>

**Status**: ACTIVE | DEPRECATED | PLANNED  
**File liên quan**: `<path>`

## Mô tả

<mô tả ngắn gọn>

## Logic chính

<giải thích logic>

## API / Interface
```

<function signatures hoặc endpoints>

```

## Edge cases đã xử lý
- <case>: <cách xử lý>

## Known issues
- <issue>
```

---

## `knowledge/issues/<id>.md` Template

```markdown
# Issue: <title>

**ID**: <id>  
**Date**: <date>  
**Severity**: LOW | MEDIUM | HIGH | CRITICAL  
**Status**: OPEN | RESOLVED | WONTFIX

## Mô tả

<mô tả vấn đề>

## Root cause

<nguyên nhân gốc>

## Cách tái hiện

1. <step>

## Giải pháp

<cách đã sửa hoặc plan sửa>

## Files bị ảnh hưởng

- `<path>`

## Notes

<bài học rút ra>
```

---

## `init/project-snapshot.md` Template

````markdown
# Project Snapshot — <date>

## Package info

<tên, version, author từ package.json/Cargo.toml/pyproject.toml>

## Dependencies chính

| Package | Version | Mục đích |
| ------- | ------- | -------- |
| <name>  | <ver>   | <why>    |

## Scripts

| Script | Lệnh  | Mục đích |
| ------ | ----- | -------- |
| <name> | <cmd> | <why>    |

## Environment variables cần thiết

- `<VAR_NAME>`: <mô tả>

## Cách chạy local

```bash
<commands>
```
````

## Cách deploy

<steps>
```
