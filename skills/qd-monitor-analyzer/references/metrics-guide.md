# Metrics Guide — /qd-performance

## Công thức chi tiết

### Work Ratio

```
Work Ratio (%) = Σ(DEEP_WORK + COMMUNICATION + RESEARCH + ADMIN) time
                ÷ Σ tổng thời gian có activity  × 100

Đánh giá:
  > 80%   → ⭐⭐⭐⭐⭐ Xuất sắc
  60–80%  → ⭐⭐⭐⭐   Tốt
  40–60%  → ⭐⭐⭐     Trung bình
  < 40%   → ⭐⭐       Cần cải thiện
```

### Focus Score (0–100)

```
Tính độ dài mỗi DEEP_WORK session liên tục (không bị interrupt bởi ENTERTAINMENT/IDLE >5 phút):

Session length → điểm đóng góp:
  ≥ 90 phút   → 100 điểm
  60–89 phút  → 80 điểm
  45–59 phút  → 60 điểm
  30–44 phút  → 40 điểm
  15–29 phút  → 20 điểm
  < 15 phút   → 5 điểm

Focus Score = weighted average (session dài được weight cao hơn)
            = Σ(session_length × session_score) ÷ Σ(session_length)

Đánh giá:
  > 75  → Deep work tốt
  50–75 → Khá, có gián đoạn nhất định
  25–50 → Nhiều context switching
  < 25  → Rất khó duy trì tập trung
```

### Context Switching Rate (CSR)

```
CSR = số lần chuyển app khác loại ÷ tổng giờ làm

Ví dụ: VS Code → Slack → VS Code = 2 lần switching
Không tính: Chrome tab → Chrome tab (cùng loại browser)

Đánh giá:
  < 3/giờ   → Focused
  3–6/giờ   → Normal
  6–10/giờ  → High switching
  > 10/giờ  → Chaotic
```

### Efficiency Score tổng hợp (0–100)

```
Efficiency = (Work Ratio_score  × 0.35)
           + (Focus Score       × 0.30)
           + (CSR_score         × 0.20)
           + (Completion_bonus  × 0.15)

CSR_score = max(0, 100 - (CSR - 3) × 10)  [3/giờ = 100 điểm, mỗi +1 trừ 10]

Completion_bonus: +15 nếu detect ≥1 commit/deploy/close-ticket/done-status patterns

Thang đánh giá:
  85–100 → ⭐⭐⭐⭐⭐ Hiệu suất rất cao
  70–84  → ⭐⭐⭐⭐   Làm việc tốt
  55–69  → ⭐⭐⭐     Trung bình khá
  40–54  → ⭐⭐       Cần cải thiện
  < 40   → ⭐         Hiệu suất thấp
```

---

## Format báo cáo performance

```markdown
# Báo cáo Hiệu suất Làm việc

**Kỳ phân tích:** [ngày cụ thể | khoảng ngày | "Toàn bộ dataset"]
**Tổng files:** N | **Tổng ngày:** D | **Tổng giờ activity:** H

---

## Tổng quan nhanh

| Chỉ số            | Giá trị     | Đánh giá     |
| ----------------- | ----------- | ------------ |
| Efficiency Score  | 72/100      | ⭐⭐⭐⭐ Tốt |
| Work Ratio        | 74%         | Tốt          |
| Focus Score       | 65/100      | Khá          |
| Context Switching | 4.2 lần/giờ | Normal       |
| Giờ làm TB/ngày   | 8.5h        |              |
| Overtime sessions | 3 lần/tuần  | Cao          |

> [1–2 câu nhận xét tổng thể ví dụ: "Nhìn chung làm việc hiệu quả, ít distraction.
> > Điểm yếu là context switching vẫn còn cao vào buổi chiều."]

---

## Phân bổ thời gian

| Category      | Thời gian | %   | So sánh tốt/xấu  |
| ------------- | --------- | --- | ---------------- |
| Deep Work     | 4.2h      | 49% | ✅               |
| Communication | 1.8h      | 21% | ✅               |
| Research      | 1.1h      | 13% | ✅               |
| Admin         | 0.5h      | 6%  | ✅               |
| Entertainment | 0.8h      | 9%  | ⚠️ (>5% giờ làm) |
| Idle          | 0.2h      | 2%  | ✅               |

---

## App & Trình duyệt sử dụng nhiều nhất

| App / Domain | Thời gian | Category         |
| ------------ | --------- | ---------------- |
| VS Code      | 3.8h      | Deep Work        |
| Chrome       | 2.1h      | Mixed            |
| Slack        | 1.2h      | Communication    |
| github.com   | 0.8h      | Research/Admin   |
| facebook.com | 0.4h      | Entertainment ⚠️ |

---

## Timeline hoạt động (heatmap text)
```

Giờ T2 T3 T4 T5 T6
07 · · · · ·
08 ██ · ███ · ██
09 ████ ████ ████ ████ ████
10 ████ ████ ████ ████ ████
11 ███ ███ ████ ███ ███
12 · ██ · · ·
13 █ █ █ · ██
14 ███ ████ ███ ████ ███
15 ████ ████ ████ ████ ████
16 ███ ████ ████ ████ ███
17 ██ ██ ███ ██ █
18 · █ · ██ ·

```
*Ký hiệu: ████ Deep Work | ▓▓▓ Communication | ░░░ Giải trí | · Idle*

---

## Thói quen & Patterns

- **Giờ vào làm thường xuyên:** ~8:30
- **Giờ kết thúc:** ~17:30 (3 ngày overtime đến 19:00+)
- **Peak performance:** 9:00–11:30
- **After-lunch slump:** 13:00–14:00 (activity thấp nhất)
- **Cuối tuần:** Có work activity 2/4 Thứ 7 trong kỳ
- **Browser chính:** Chrome (78%), Firefox (22%)

---

## Điểm mạnh
- ...

## Cần cải thiện
- ...

## Khuyến nghị
- ...
```
