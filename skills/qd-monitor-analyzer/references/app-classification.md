# App & Domain Classification — /qd-performance

## Applications → Category

### DEEP_WORK

**IDEs:** VS Code, IntelliJ, WebStorm, PyCharm, Xcode, Android Studio, Vim, Neovim, Sublime Text, Cursor, Zed  
**Design:** Figma, Adobe XD, Sketch, Photoshop, Illustrator  
**Data:** Excel (complex formulas/pivot), Jupyter Notebook, Tableau, Power BI, DBeaver, DataGrip  
**Writing:** Google Docs (long form), Notion (writing mode), Obsidian, Word  
**Terminal:** Terminal, iTerm, Windows Terminal, PowerShell, CMD, bash

### COMMUNICATION

Slack, Microsoft Teams, Discord (work server), Telegram (work), Zalo (work context)  
Gmail, Outlook, Thunderbird, Apple Mail  
Zoom, Google Meet, Webex  
GitHub PR comments, Jira comments, Linear comments

### RESEARCH

**Work domains:** Stack Overflow, MDN, GitHub, npmjs.com, docs._, _.readthedocs.io, devdocs.io  
**AI tools:** ChatGPT, Claude, Copilot, Perplexity, Gemini  
**Learning:** Udemy, Coursera, YouTube (nếu title có "tutorial", "learn", "course", "how to")  
**API tools:** Postman, Insomnia, TablePlus, MongoDB Compass

### ADMIN

Jira, Trello, Asana, Linear, ClickUp, Notion (board/task view)  
GitHub Desktop, SourceTree, GitLens  
Finder/Explorer, Google Drive, Dropbox (work files)  
Google Calendar, Outlook Calendar

### ENTERTAINMENT

**Social:** Facebook, Instagram, TikTok, Twitter/X (unless work-related)  
**Video:** YouTube (non-tutorial), Netflix, Disney+, VieON, Zing TV  
**News:** VnExpress, Dân Trí, Tuổi Trẻ, 24h.com.vn  
**Games:** Steam, game executables, browser games  
**Shopping:** Shopee, Lazada, Tiki, Grab Food

### IDLE

Lock screen, screensaver, desktop (không có window active), screen blank

---

## Domain → Category lookup

### RESEARCH domains

```
github.com, gitlab.com, bitbucket.org
stackoverflow.com, stackexchange.com
npmjs.com, pypi.org, crates.io
developer.mozilla.org, docs.microsoft.com
*.readthedocs.io, docs.*, api.*
figma.com (viewing specs), miro.com
chatgpt.com, claude.ai, perplexity.ai
```

### ADMIN domains

```
jira.*.com, linear.app, trello.com, asana.com
notion.so (board/kanban view), confluence.*
github.com (issues/PRs), gitlab.com (issues)
calendar.google.com, outlook.live.com
```

### ENTERTAINMENT domains

```
facebook.com, instagram.com, tiktok.com
youtube.com (check title — tutorial → RESEARCH, else ENTERTAINMENT)
twitter.com, x.com
vnexpress.net, dantri.com.vn, tuoitre.vn, 24h.com.vn
shopee.vn, lazada.vn, tiki.vn
reddit.com (non-technical subreddits → ENTERTAINMENT)
```

### Context-dependent

```
google.com → check search query nếu có
  - "how to fix...", "react docs", "npm install..." → RESEARCH
  - news, celebrities, shopping → ENTERTAINMENT
gmail.com → COMMUNICATION
drive.google.com → ADMIN hoặc DEEP_WORK (tùy context)
meet.google.com → COMMUNICATION
youtube.com → check video title/description trong OCR
  - "tutorial", "learn", "course", "how to", "[language] for beginners" → RESEARCH
  - entertainment, music, vlogs → ENTERTAINMENT
news.ycombinator.com → RESEARCH nếu đang đọc tech thread
```

---

## Nhận diện trình duyệt từ OCR

Nhận dạng từ UI elements trong screenshot:

- **Chrome:** Thanh địa chỉ có hình tròn tìm kiếm, tab style Chrome, dấu khóa bên trái URL
- **Firefox:** Logo Firefox, tab style khác Chrome, "Firefox" trong title bar
- **Edge:** Logo Edge (chữ e xanh), "Microsoft Edge" trong title
- **Safari:** "Safari" trong menu bar macOS, reader view icon
- **Brave:** Logo Brave (sư tử), thường có "Brave" label

Nếu không xác định được → ghi "Browser (unknown)"
