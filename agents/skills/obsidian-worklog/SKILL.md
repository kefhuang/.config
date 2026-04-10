---
name: obsidian-worklog
description: Sync current work session summary to Obsidian vault as a daily work log entry. Trigger with /obsidian-worklog or "sync work log to obsidian".
---

总结工作内容并写入 Obsidian vault。

## 步骤

1. **识别项目**：运行 `git remote get-url origin` 提取 repo 名（取最后一段，去掉 .git）。如果没有 git remote 则用当前目录名。

2. **确定路径**：
   - vault 基础路径：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/KefengsObsidian/WorkLog/{project}/`
   - 目标文件：`{YYYY-MM-DD}.md`（今天的日期）

3. **获取工作内容**：
   - 如果你在当前对话中（有上下文）：直接从对话上下文总结
   - 如果收到 transcript 文件路径：读取该文件来总结

4. **判断是否有实质工作**：如果只是闲聊/简单问答，不写入任何内容，直接结束。

5. **写入 vault**：
   - 如果目标文件已存在：读取内容，在末尾追加新条目
   - 如果不存在：创建文件，顶部加 `# {project} - {YYYY-MM-DD}`

6. **清理**：Kill 掉 `/tmp/claude-obsidian-*.pid` 里的 pending timer（读取 PID，kill 它，删除 pid 文件），避免重复写入。

## 条目格式

```
## HH:MM - 简短标题

### 做了什么
- 要点 1
- 要点 2

### 关键文件
- path/to/file - 改了什么

### 标签
[[tag1]] [[tag2]]

---
```

## 要求
- 用中文写摘要
- 只记录实质工作内容，忽略闲聊和简单问答
