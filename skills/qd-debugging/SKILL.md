---
name: qd-debugging
description: All-in-one debugging workflow for any project issue (build, runtime, test, syntax, integration) with log-driven root cause analysis, systematic debugging phases, and verification-before-completion gates.
triggers:
  - /qd-debugging
  - debug after update
  - fix build error
  - fix runtime error
  - analyze error log
---

# /qd-debugging

Skill debug tong quat, khong gioi han chi cho dependency update.

## Input modes

Ho tro 2 kieu dau vao:

1. User mo ta loi + command bi fail.
2. User cung cap file log/error dump.

Neu co log file, uu tien parse log truoc.

## Integrated Patterns

- `systematic-debugging`: root-cause truoc, khong fix doan.
- `verification-before-completion`: khong bao done neu chua co evidence moi.
- `test-driven-development`: khi sua bug quan trong, tao reproducer test.
- OMC multi-agent style: co the chia nhiem vu song song (breaking-change analyst, compile fixer, test runner).
- Ralph persistence mindset: lap fix-den-khi-qua gate (co max-attempt policy).

## 11-Phase Debug Flow

### Phase 1 - Problem framing

Xac dinh:

- symptom
- expected behavior
- impact scope
- reproducibility

### Phase 2 - Evidence collection

Thu thap:

- stack trace
- build log
- test output
- dev server log
- git diff gan day

Khong de xuat fix truoc khi co evidence.

### Phase 3 - Error classification

Phan loai:

- compile/build error
- runtime error
- syntax error
- type error
- test regression
- integration/config error

### Phase 4 - Root cause hypothesis

Voi moi huong nghi ngo:

1. ghi ro hypothesis
2. chay 1 test nho de xac minh
3. loai bo neu khong dung

### Phase 5 - Parallel specialist dispatch (optional)

Neu task lon/co nhieu nhom loi, cho phep chia:

- agent A: check breaking changes / docs mismatch
- agent B: fix compile/type errors
- agent C: run tests + summarize failures

### Phase 6 - Minimal fix implementation

Fix tai goc loi, khong chua symptom.
Moi lan chi thay doi nho, de verify duoc.

### Phase 7 - Verification loop

Sau moi fix:

1. re-run command loi ban dau
2. build/type/lint/test lien quan
3. runtime smoke check (neu app)

### Phase 8 - TDD reinforcement (recommended)

Neu bug co kha nang tai dien:

1. viet failing test (RED)
2. fix de GREEN
3. giu test de chan regression

### Phase 9 - Completion gate

Chi duoc ket luan "fixed" khi:

- command fail ban dau da pass
- khong con error cung loai trong logs moi
- co output verification moi (fresh run)

### Phase 10 - Recovery options

Neu dat max attempts ma chua pass:

- rollback
- defer voi known workaround
- tach nho scope de debug tiep

### Phase 11 - Debug report

Output bat buoc:

- Observed failure
- Root cause
- Evidence
- Fix da ap dung
- Verification evidence
- Remaining risk (neu co)

## Error-log-first protocol

Neu user dua log file:

1. parse top 3 error signatures
2. map signature -> likely root cause cluster
3. uu tien fix theo thu tu:
   - syntax/parse blockers
   - missing module/import errors
   - type/API mismatch
   - business logic regression

## Rules

- Khong fix khi chua root-cause analysis.
- Khong claim complete khi chua re-run verification.
- Uu tien reproducible steps.
- Luon de lai rollback/defer option neu khong close duoc trong budget.
