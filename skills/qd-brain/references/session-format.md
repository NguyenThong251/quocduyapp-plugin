# Session Format — QD-Brain

## Nguyên tắc lưu session

### Compact first

Session history phải **ngắn gọn nhưng đầy đủ**. Mục tiêu: agent mới đọc trong < 2 phút hiểu được đầy đủ context.

### Lưu WHAT và WHY, không lưu HOW chi tiết

- ✅ "Đã quyết định dùng Redis cho session thay vì DB vì latency"
- ❌ "Cài redis bằng npm install ioredis sau đó import vào file..."

### Lưu những gì có thể thay đổi quyết định

- Tradeoffs đã cân nhắc
- Assumptions đã đặt ra
- Constraints phát hiện

---

## Format `session/history/YYYY-MM-DD_HH-MM.md`

```markdown
# Session <YYYY-MM-DD HH:MM> → <HH:MM>

**Focus**: <một dòng mô tả session này làm gì>

## Accomplished

- <item>
- <item>

## Decisions Made

| Quyết định | Lý do | Alternatives đã loại |
| ---------- | ----- | -------------------- |
| <decision> | <why> | <rejected options>   |

## Issues Found

| Issue   | Severity | Status   |
| ------- | -------- | -------- |
| <issue> | HIGH     | RESOLVED |

## New Rules/Patterns

- <rule>: <context>

## Files Changed

- `<path>`: <thay đổi gì>

## Blockers / Open Questions

- <item>

## Session Summary (1-2 dòng)

<tóm tắt ngắn nhất có thể>
```

---

## Format `session/current.md`

Đây là file **live** — cập nhật liên tục trong session.

```markdown
# Current Session — <YYYY-MM-DD HH:MM>

## Objectives

- [ ] <mục tiêu 1>
- [ ] <mục tiêu 2>

## Timeline

- <HH:MM> — Bắt đầu, context: <handoff summary>
- <HH:MM> — <action>
- <HH:MM> — <decision>: <lý do>
- <HH:MM> — <issue phát hiện>
- <HH:MM> — <resolution>

## Active Plan

Đang thực thi: `.doc/plan/active/<feature>.md`
Step hiện tại: <step number và mô tả>

## Running Notes

<ghi chú tự do, xóa sau khi archive>
```

---

## Quy tắc archive session

Khi kết thúc session, thực hiện:

```
1. Đọc session/current.md
2. Extract: accomplished, decisions, issues, new rules, files changed
3. Tạo session/history/YYYY-MM-DD_HH-MM.md theo format trên
4. Tạo/cập nhật session/handoff.md
5. Reset session/current.md cho session mới
6. Cập nhật .doc/CLAUDE.md dòng "Cập nhật lần cuối"
```

---

## Handoff Note Quality Checklist

Một handoff tốt phải trả lời được:

- [ ] Agent mới đang ở bước nào?
- [ ] Việc gì đang còn dang dở?
- [ ] Có risk hoặc blocker nào không?
- [ ] Bước tiếp theo là gì cụ thể?
- [ ] Có context đặc biệt nào cần biết không?

---

## Khi mở session mới trên máy khác

Script khởi động (agent tự chạy khi thấy `.doc/` tồn tại):

```
1. Đọc .doc/CLAUDE.md
2. Đọc .doc/session/handoff.md
3. Đọc .doc/session/current.md (nếu có content dang dở)
4. Đọc .doc/rules/ (tất cả files)
5. Hỏi người dùng: "Tôi đã đọc context. [Tóm tắt handoff 2-3 dòng]. Bạn muốn tiếp tục từ đâu?"
```
