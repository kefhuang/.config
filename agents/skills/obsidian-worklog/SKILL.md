---
name: obsidian-worklog
description: Sync current work session summary to Obsidian vault as a daily work log entry. Trigger with /obsidian-worklog or "sync work log to obsidian".
---

总结工作内容并写入 Obsidian vault。

## 步骤

1. **识别项目**：从 prompt 参数获取项目名。如果没有，运行 `git remote get-url origin` 提取 repo 名（取最后一段，去掉 .git）。如果没有 git remote 则用当前目录名。去掉前导 `.`。

2. **确定路径**：
   - 目标文件由 prompt 参数 `目标文件` 指定
   - 如果没有指定：vault 从 `~/.claude/settings.local.json` 的 `env.OBSIDIAN_VAULT` 读取，fallback 为 `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/KefengsObsidian`，文件为 `{vault}/Raw/WorkLog/{YYYY-MM-DD}.md`

3. **获取工作内容**：直接从当前对话上下文总结（hook 通过 --resume 提供完整对话历史）。

4. **判断是否有实质工作**：如果只是闲聊/简单问答，不写入任何内容，直接结束。

5. **写入文件**：
   - 如果目标文件已存在：读取内容，在末尾追加新条目
   - 如果不存在：创建文件，顶部加 `# WorkLog - {YYYY-MM-DD}`

## 条目格式

```
## HH:MM - [项目名] 简短标题

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
- 项目名放在条目标题里，不用目录区分
