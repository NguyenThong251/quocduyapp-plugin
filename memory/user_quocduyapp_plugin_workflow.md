---
name: quocduyapp-plugin-workflow
description: Project context for quocduyapp-plugin dependency management workflow
type: project
---

# QuocDuyApp Plugin - Dependency Management Workflow

## Project
- **Repo:** https://github.com/NguyenThong251/quocduyapp-plugin
- **Purpose:** Claude Code plugin for dependency management (/qd-outdated, /qd-update)
- **User:** Nguyễn Hoàng Thông

## Skills Enhanced (Today - 2026-04-17)

### /qd-outdated - Dependency Audit
- **Version-by-Version Analysis:** Phân tích chi tiết từng version khi major upgrade
- **Source Code Analysis (Phase 6.5 - MANDATORY):** Scan actual source code trước khi kết luận
  - Grep imports, count files, calculate impact %
  - Pros/Cons breakdown cho project
  - Recommendation Matrix với weighted scoring (1-5)
  - FINAL VERDICT: UPGRADE NOW / UPGRADE WITH CARE / DEFER
- **Update Roadmap with Phases:** Chia nhỏ major update thành từng phase rõ ràng
- **Decision Support với TL;DR:** So sánh old vs new metrics (bundle, perf, security)
- **Auto-generate:** UPDATE-ROADMAP.md alongside CHANGELOG_DEPENDENCY_UPDATE.md

### /qd-update - Safe Dependency Update
- **Step 5.0 (MANDATORY):** Clean Old Artifacts trước rebuild
  - Xóa: dist, .next, *.tsbuildinfo, node_modules/.cache, .eslintcache
- **Library Addition Controls:** Không tự ý thêm library
  - Phải confirm + giải thích rõ library giải quyết vấn đề gì
  - Template: Package, Purpose, Problem, What This Solves, Risk
- **Step 5b ABANDON & REBUILD:** Paradigm Shift Detection
  - OPTION A: UNDO & ABANDON (Giữ version cũ)
  - OPTION B: OK & PROCEED (Chấp nhận refactor lớn)
  - OPTION C: DEFER (Bookmark để làm sau)

## Key Workflow
```
/qd-outdated
  → Scan source (Phase 6.5) — thực sự đọc code
  → Generate CHANGELOG + UPDATE-ROADMAP
  → Decision Support với TL;DR
  → User decide: upgrade hay không

/qd-update <package>
  → Clean artifacts (Step 5.0)
  → Confirm trước khi add library mới
  → Verify: build → test → bundle size
  → Nếu paradigm shift → UNDO/PROCEED/DEFER
  → Commit từng phase
```

## Why (Context)
- User là senior developer, muốn tool đưa ra quyết định dựa trên thực tế source code
- Không muốn tự ý thêm library — phải confirm + giải thích
- Cần clean cache trước build để tránh lỗi ẩn
- Cần option abandon khi effort > value
- Cần TL;DR comparison giữa old vs new
