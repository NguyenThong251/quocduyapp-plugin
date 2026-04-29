---
name: qd-analyzer
description: >
  Bộ công cụ phân tích toàn diện dataset .md files OCR từ screenshot máy tính.
  Hỗ trợ 3 lệnh (slash commands):

  /qd-security-audit — Quét bảo mật: phát hiện credentials, API keys, passwords, URLs
  nội bộ, PII, nội dung nhạy cảm, rò rỉ thông tin sản phẩm. Xuất báo cáo risk-scored.

  /qd-performance — Đánh giá hiệu suất làm việc: app sử dụng, work ratio, focus score,
  thói quen, context switching, productivity timeline. Mặc định toàn bộ dataset nếu không truyền ngày.

  /qd-extractor — Trích xuất kỹ năng & quy trình: tạo SKILL.md chuẩn cho AI agent học,
  map MCP actions, đánh giá automation potential, agent replacement readiness score.

  Kích hoạt khi người dùng gõ bất kỳ lệnh /qd-* nào, đề cập "phân tích screenshot OCR",
  "audit dataset md", "kiểm tra bảo mật file md", "đánh giá nhân viên từ screenshot",
  "tạo skill từ OCR", "qd security", "qd performance", "qd extractor". Luôn dùng skill
  này khi có dataset .md files từ OCR screenshot và cần phân tích bất kỳ khía cạnh nào.
---

# QD Analyzer — Bộ công cụ phân tích OCR Dataset

Ba công cụ phân tích chuyên biệt cho dataset .md files OCR từ screenshot máy tính.

---

## Cách sử dụng

Người dùng gõ một trong các lệnh sau:

| Lệnh                 | Chức năng                                      |
| -------------------- | ---------------------------------------------- |
| `/qd-security-audit` | Kiểm tra bảo mật & thống kê thông tin nhạy cảm |
| `/qd-performance`    | Đánh giá hiệu suất & hành vi làm việc          |
| `/qd-extractor`      | Trích xuất kỹ năng → tạo SKILL.md cho AI agent |

Sau khi nhận lệnh, hỏi thêm nếu thiếu thông tin bắt buộc (thư mục input), rồi thực thi ngay.

---

## /qd-security-audit

**Mục tiêu:** Quét toàn bộ dataset, phát hiện và thống kê mọi thông tin có nguy cơ bảo mật.

### Input

```
/qd-security-audit --dir <thư mục>
                   --output <file output>     # mặc định: security-report-YYYY-MM-DD.md
                   --severity ALL|HIGH|CRITICAL  # mặc định: ALL
                   --include-context          # hiện đoạn văn xung quanh phát hiện
```

Nếu thiếu `--dir`, hỏi người dùng trước khi chạy.

### 7 Nhóm Detection

**Nhóm 1 — URLs & Endpoints** (risk: LOW → HIGH)

```regex
https?://[^\s"'<>]+
localhost:\d+
127\.0\.0\.1:\d+
192\.168\.\d+\.\d+
10\.\d+\.\d+\.\d+
/api/v\d+/
/graphql
/webhook
```

Phân loại: public URL → LOW, internal IP/endpoint → MEDIUM/HIGH

**Nhóm 2 — Credentials** (risk: CRITICAL)

```regex
password\s*[:=]\s*\S+
passwd\s*[:=]\s*\S+
pass\s*[:=]\s*\S+
username\s*[:=]\s*\S+
user\s*[:=]\s*["']?\w+["']?
login\s*[:=]\s*\S+
```

**Nhóm 3 — API Keys & Tokens** (risk: CRITICAL)

```regex
api[_-]?key\s*[:=]\s*\S+
token\s*[:=]\s*\S+
secret\s*[:=]\s*\S+
bearer\s+[A-Za-z0-9\-._~+/]+=*
Authorization:\s*\S+
sk-[a-zA-Z0-9]{20,}
ghp_[a-zA-Z0-9]{36}
AKIA[A-Z0-9]{16}
```

**Nhóm 4 — File Paths Nhạy Cảm** (risk: HIGH)

```
/etc/passwd  /etc/shadow  /etc/hosts
.env  .env.local  .env.production
/home/\w+/.ssh/
config.json  secrets.yaml  credentials.json
C:\Users\...\AppData
```

**Nhóm 5 — Database Connection Strings** (risk: CRITICAL)

```regex
mongodb(\+srv)?://\S+
mysql://\S+
postgresql://\S+
redis://\S+
Server=.*;Database=.*;User Id=
```

**Nhóm 6 — PII** (risk: MEDIUM → HIGH)

```regex
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}   # email
(0|\+84)[0-9]{8,9}                                  # phone VN
\b\d{9}\b  hoặc  \b\d{12}\b                         # CMND/CCCD
```

- Họ tên khi xuất hiện cạnh "tên:", "họ tên:", "full name:"

**Nhóm 7 — Nội Dung Nhạy Cảm** (risk: HIGH → CRITICAL)
Từ khóa context:

```
hợp đồng, lương, thưởng, sa thải, từ chức
NDA, confidential, internal only, do not share
pricing internal, roadmap, unreleased
```

### Xử lý & Output

1. **Deduplicate** — gom phát hiện giống nhau xuất hiện nhiều file
2. **Sort** CRITICAL → HIGH → MEDIUM → LOW
3. **Mask** giá trị: password → `pa****`, API key → `sk-ab...[REDACTED]`
4. **Cảnh báo ngay** nếu phát hiện >10 CRITICAL trước khi tiếp tục

Đọc `references/security-report-format.md` để format báo cáo đúng chuẩn.

---

## /qd-performance

**Mục tiêu:** Đánh giá toàn diện hành vi và hiệu suất làm việc từ activity trên màn hình.

### Input

```
/qd-performance --dir <thư mục>
                --date YYYY-MM-DD              # filter ngày cụ thể
                --range YYYY-MM-DD YYYY-MM-DD  # filter khoảng ngày
                --output <file>                # mặc định: performance-report.md
# Không truyền ngày → phân tích TOÀN BỘ dataset (mặc định)
```

**Xác định ngày từ file:** Tên file pattern `screenshot-YYYY-MM-DD-HH-MM.md` hoặc `YYYYMMDD_HHMMSS.md`. Nếu không có, tìm timestamp trong nội dung OCR.

### Phân loại hoạt động

Phân mỗi screenshot vào category:

| Category        | Ví dụ                                               |
| --------------- | --------------------------------------------------- |
| `DEEP_WORK`     | IDE, code editor, design tool, spreadsheet phức tạp |
| `COMMUNICATION` | Slack, email, Zoom, Teams, Zalo                     |
| `RESEARCH`      | Docs, Stack Overflow, ChatGPT, YouTube tutorial     |
| `ADMIN`         | Jira, Trello, Calendar, file manager                |
| `ENTERTAINMENT` | YouTube non-work, Facebook, TikTok, game            |
| `IDLE`          | Desktop, lock screen, screensaver                   |

Tra cứu phân loại app/domain cụ thể tại `references/app-classification.md`.

### Metrics tính toán

**Work Ratio (%)** = (DEEP_WORK + COMMUNICATION + RESEARCH + ADMIN) ÷ tổng thời gian × 100

- > 80% Xuất sắc | 60–80% Tốt | 40–60% Trung bình | <40% Cần cải thiện

**Focus Score (0–100)** — dựa trên độ dài session DEEP_WORK liên tục không bị interrupt:

- Session ≥90 phút liên tục → max score | <15 phút → low score

**Context Switching Rate** = số lần đổi app ÷ giờ làm

- <3/giờ Focused | 3–6 Normal | 6–10 High | >10 Chaotic

**Efficiency Score (0–100)** = Work Ratio×0.35 + Focus Score×0.30 + (100-CSR_norm)×0.20 + Completion bonus×0.15

**Thói quen phát hiện:**

- Giờ vào làm (mode of first activity timestamp)
- Peak performance hours (giờ có DEEP_WORK dày nhất)
- Lunch break (idle 30–60 phút giữa ngày)
- Overtime (activity sau 18:00)
- Weekend work

Đọc `references/metrics-guide.md` để tính và format chi tiết.

---

## /qd-extractor

**Mục tiêu:** Trích xuất kỹ năng + quy trình → tạo SKILL.md chuẩn để AI agent học và thay thế.

### Input

```
/qd-extractor --dir <thư mục>
              --role <tên vai trò>      # optional, ví dụ: "frontend-dev"
              --output <file>           # mặc định: SKILL-[role].md
              --depth basic|full        # mặc định: full
```

### Trích xuất signals

**Technical signals:**

- Ngôn ngữ lập trình (từ syntax, file extensions, error messages)
- Frameworks & libraries (import statements, package files trong màn hình)
- Tools & services (tên app, CLI commands, API endpoints)
- Code patterns (naming conventions, architecture style)

**Workflow signals:**

- Sequences of actions lặp lại → đây là workflow patterns
- Decision points (khi nào làm A thay vì B)
- Error patterns (lỗi gì hay gặp → fix thế nào)
- Search behavior (hay tìm gì trên Google/SO)

**Quality signals:** Code review habits, documentation, testing frequency

### Automation Tier Assessment

Với mỗi workflow pattern, phân loại:

| Tier       | Mô tả                   | Ví dụ                                     |
| ---------- | ----------------------- | ----------------------------------------- |
| **Tier 1** | Agent tự làm hoàn toàn  | Tạo ticket, search code, generate PR desc |
| **Tier 2** | Agent làm, human review | Code review, draft email, update status   |
| **Tier 3** | Human-in-loop           | Architecture decision, design review      |
| **Tier 4** | Human only              | Creative direction, negotiation, empathy  |

### MCP Actions Mapping

Map mỗi workflow action sang MCP tool:

| Workflow               | MCP Tool                                            |
| ---------------------- | --------------------------------------------------- |
| Tạo GitHub issue/PR    | `github:create_issue`, `github:create_pull_request` |
| Đọc/ghi file           | `filesystem:read_file`, `filesystem:write_file`     |
| Web search / đọc trang | `brave_search`, `fetch:fetch`                       |
| Jira tickets           | `jira:create_issue`, `jira:update_issue`            |
| Slack message          | `slack:send_message`                                |
| Database query         | `postgres:query`, `sqlite:query`                    |
| Terminal commands      | `bash` (Claude Code only)                           |

Tra cứu đầy đủ tại `references/mcp-mapping.md`.

### Output SKILL.md structure

File output phải có đủ các sections:

1. **Frontmatter** — name, description, source
2. **Technical Skills** — languages, frameworks, tools (với proficiency)
3. **Workflow Patterns** — daily routine, feature dev, bug fix, đặc thù riêng
4. **Communication Style** — với team, stakeholder, trong PR
5. **Decision-Making Patterns** — bảng tình huống → hành vi thường thấy
6. **MCP Actions Map** — Tier 1/2/3 với input/output rõ ràng
7. **Điểm mạnh** — agent nên học và replicate
8. **Điểm yếu** — agent có thể làm tốt hơn
9. **Agent Replacement Readiness** — score 0–10 từng dimension + khuyến nghị
10. **Prompt templates** — mẫu prompt cho agent khi nhận task mới

Đọc `references/skill-output-template.md` để format từng section đúng chuẩn.

---

## Nguyên tắc chung cho cả 3 lệnh

- **Luôn hỏi confirm thư mục** nếu người dùng chưa chỉ định
- **Báo tiến độ** khi xử lý dataset lớn: "Đang xử lý file 45/312..."
- **Xử lý chunk** với file >1MB để tránh timeout
- **File output** đặt cạnh thư mục input hoặc theo `--output` người dùng chỉ định
- **Tóm tắt ngắn** ở đầu mỗi báo cáo để người dùng nắm nhanh không cần đọc hết
