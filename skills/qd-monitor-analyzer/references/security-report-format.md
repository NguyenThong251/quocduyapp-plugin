# Security Report Format

## Tên file output

`security-report-YYYY-MM-DD.md`

---

## Template báo cáo

```markdown
# Báo cáo Bảo mật — [Tên thư mục / Project]

**Ngày quét:** YYYY-MM-DD HH:MM  
**Tổng files quét:** N | **Files có vấn đề:** M  
**Tổng phát hiện:** X — CRITICAL: a | HIGH: b | MEDIUM: c | LOW: d

---

## ⚠️ Tóm tắt nguy cơ

> 3–5 dòng nêu những vấn đề nghiêm trọng nhất cần xử lý ngay.
> Người đọc lướt qua đây là đủ biết ưu tiên gì.

---

## 1. Credentials (CRITICAL)

### 1.1 Passwords

| File              | Dòng | Giá trị (masked)   | Risk     |
| ----------------- | ---- | ------------------ | -------- |
| screenshot-abc.md | 42   | `password: pa****` | CRITICAL |

### 1.2 API Keys & Tokens

| File             | Dòng | Loại         | Giá trị (masked)       |
| ---------------- | ---- | ------------ | ---------------------- |
| config-screen.md | 15   | GitHub token | `ghp_xK3...[REDACTED]` |

### 1.3 Database Connection Strings

[bảng tương tự]

---

## 2. URLs & Endpoints

### 2.1 Internal IPs & Endpoints (HIGH)

| URL / Endpoint                      | Xuất hiện | Files                |
| ----------------------------------- | --------- | -------------------- |
| http://192.168.1.100:8080/api/admin | 3 lần     | file-a.md, file-b.md |

### 2.2 Public URLs đáng chú ý (LOW–MEDIUM)

| Domain                          | Lần | Ghi chú                |
| ------------------------------- | --- | ---------------------- |
| github.com/company/private-repo | 5   | Có thể là repo private |

---

## 3. Thông tin cá nhân — PII

### 3.1 Email

### 3.2 Số điện thoại

### 3.3 CMND / CCCD / Tên thật

---

## 4. Nội dung nhạy cảm

### 4.1 Thông tin nội bộ công ty

### 4.2 Nội dung chat / trao đổi nhạy cảm

### 4.3 Rò rỉ sản phẩm / roadmap

---

## 5. File Paths Hệ thống (HIGH)

---

## 6. Thống kê theo file

| File              | CRITICAL | HIGH | MEDIUM | LOW | Tổng |
| ----------------- | -------- | ---- | ------ | --- | ---- |
| screenshot-abc.md | 2        | 1    | 3      | 5   | 11   |

**Files sạch (0 phát hiện):** [danh sách tên file]

---

## 7. Khuyến nghị

### Xử lý ngay (CRITICAL)

- [ ] Revoke/đổi tất cả credentials bị lộ
- [ ] Kiểm tra access log xem đã bị dùng chưa
- [ ] Xóa hoặc encrypt các file chứa thông tin nhạy cảm

### Xử lý trong tuần (HIGH)

- [ ] ...

### Xem xét (MEDIUM/LOW)

- [ ] ...

---

_Báo cáo tạo bởi qd-analyzer / security-audit_
```

---

## Quy tắc masking giá trị nhạy cảm

| Loại         | Mask rule                          | Ví dụ                  |
| ------------ | ---------------------------------- | ---------------------- |
| Password     | 2 ký tự đầu + `****`               | `pa****`               |
| API key ngắn | 4 ký tự đầu + `...[REDACTED]`      | `sk-ab...[REDACTED]`   |
| Token dài    | prefix pattern + `[REDACTED]`      | `ghp_xK3...[REDACTED]` |
| Email        | local part ẩn + domain ẩn một phần | `us**@gm***.com`       |
| Phone VN     | giữ 3 đầu + 3 cuối                 | `090****789`           |
| CMND/CCCD    | giữ 3 đầu + `*****`                | `012*****`             |

Mục đích: người dùng nhận ra đây là giá trị nào mà không expose toàn bộ trong log.
