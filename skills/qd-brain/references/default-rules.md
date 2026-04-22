# Git Rules

## ⚠️ QUAN TRỌNG NHẤT

**KHÔNG BAO GIỜ tự ý git push** — dù là push lên branch của mình.
Luôn phải hỏi và được xác nhận từ người điều khiển trước.

## Commit Convention

Format: `type(scope): mô tả ngắn gọn`

Types:

- `feat`: tính năng mới
- `fix`: sửa bug
- `refactor`: cải thiện code không thêm feature/fix bug
- `docs`: chỉ thay đổi tài liệu
- `test`: thêm/sửa test
- `chore`: build system, dependencies
- `hotfix`: fix khẩn cấp trên production

Ví dụ:

- `feat(auth): add JWT refresh token`
- `fix(cart): correct total calculation on empty cart`
- `hotfix(payment): patch null pointer in checkout`

## Branch Naming

- Feature: `feature/<tên-ngắn-gọn>`
- Bug fix: `fix/<issue-id-hoặc-mô-tả>`
- Hotfix: `hotfix/<mô-tả>`
- Release: `release/<version>`

## Pull Request

- Phải có description trước khi merge
- Không merge PR chưa được review (nếu có team)
- Squash commit lại nếu có nhiều commit lặt vặt

## Hotfix Process

1. Tạo branch `hotfix/<mô-tả>`
2. Fix + test
3. Commit với prefix `hotfix:`
4. Báo cáo người điều khiển để confirm push
5. Merge vào main/production sau khi được phép
