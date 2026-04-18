---
name: quocduyapp-plugin-workflow
description: quocduyapp-plugin project workflow rules - build-only, no tests, no external source edits
type: feedback
---

## quocduyapp-plugin Workflow Rules

**Rule**: Chỉ build/enhance skills theo yêu cầu. Không cần test case. Không sửa đổi các source ngoài phạm vi project plugin này.

**Why**: Đây là plugin cho Claude Code — mục đích là tạo skill documentation/workflows, không phải test hay sửa code thực tế. Các enhanced features được test trong workflow của chính nó khi user invoke.

**How to apply**: Khi nhận yêu cầu về quocduyapp-plugin, chỉ tập trung vào việc update/cải thiện SKILL.md và các file trong `skills/` của plugin. Không cần viết tests, không cần chỉnh sửa source code của các project khác (React Native, seomachine, etc.).
