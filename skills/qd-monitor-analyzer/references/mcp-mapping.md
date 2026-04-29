# MCP Tools Mapping — /qd-extractor

## GitHub / GitLab

| Workflow action     | MCP Tool                       | Key parameters                      |
| ------------------- | ------------------------------ | ----------------------------------- |
| Đọc file trong repo | `github:get_file_contents`     | owner, repo, path                   |
| Tạo/update file     | `github:create_or_update_file` | owner, repo, path, content, message |
| Tạo issue           | `github:create_issue`          | owner, repo, title, body, labels    |
| List issues         | `github:list_issues`           | owner, repo, state, labels          |
| Tạo PR              | `github:create_pull_request`   | title, body, head, base             |
| List PRs            | `github:list_pull_requests`    | state, head, base                   |
| Search code         | `github:search_code`           | query                               |
| Get PR details      | `github:get_pull_request`      | owner, repo, pull_number            |

## Filesystem (local)

| Action         | MCP Tool                    |
| -------------- | --------------------------- |
| Đọc file       | `filesystem:read_file`      |
| Ghi file       | `filesystem:write_file`     |
| List directory | `filesystem:list_directory` |
| Search files   | `filesystem:search_files`   |
| Move file      | `filesystem:move_file`      |
| Get file info  | `filesystem:get_file_info`  |

## Web & Research

| Action      | MCP Tool                         |
| ----------- | -------------------------------- |
| Web search  | `brave_search:brave_web_search`  |
| Đọc webpage | `fetch:fetch`                    |
| Search news | `brave_search:brave_news_search` |

## Jira / Project Management

| Action            | MCP Tool             |
| ----------------- | -------------------- |
| Đọc ticket        | `jira:get_issue`     |
| Tạo ticket        | `jira:create_issue`  |
| Update status     | `jira:update_issue`  |
| Tìm tickets (JQL) | `jira:search_issues` |
| Add comment       | `jira:add_comment`   |
| List projects     | `jira:list_projects` |

## Slack / Communication

| Action          | MCP Tool                    |
| --------------- | --------------------------- |
| Gửi message     | `slack:send_message`        |
| Đọc channel     | `slack:get_channel_history` |
| Search messages | `slack:search_messages`     |
| List channels   | `slack:list_channels`       |

## Google Workspace

| Action       | MCP Tool                    |
| ------------ | --------------------------- |
| List files   | `google_drive:list_files`   |
| Đọc file/doc | `google_drive:get_file`     |
| Tạo doc      | `google_drive:create_file`  |
| Search drive | `google_drive:search_files` |

## Database

| Action         | MCP Tool                             |
| -------------- | ------------------------------------ |
| Query          | `postgres:query` hoặc `sqlite:query` |
| List tables    | `postgres:list_tables`               |
| Describe table | `postgres:describe_table`            |

## Terminal / System (Claude Code only)

| Action         | Tool               |
| -------------- | ------------------ |
| Run commands   | `bash`             |
| Python scripts | `bash` với python3 |
| Git operations | `bash` với git CLI |

---

## Automation Feasibility Matrix

| Điều kiện                                           | Tier                          |
| --------------------------------------------------- | ----------------------------- |
| Input/output xác định rõ, không có judgment         | Tier 1                        |
| Cần context từ nhiều nguồn, output review được      | Tier 2                        |
| Cần judgment call, nhưng agent có thể propose       | Tier 3                        |
| Empathy, creativity, legal, business strategy       | Tier 4                        |
| Real-time data cần                                  | Tier 1 (với web_search/fetch) |
| Auth/permission ngoài MCP scope                     | Tier 3–4                      |
| Side effects khó rollback (delete, send email thật) | Tier 2 (cần confirm)          |
| Sensitive data involved                             | Tier 2–3                      |
