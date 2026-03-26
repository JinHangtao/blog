# 📝 articles.json 新文章模板

粘贴位置：打开 `articles.json`，找到第一行 `[`，
在它下面、第一篇文章的 `{` **之前**插入新文章，末尾记得加 `,`。

---

## ✦ 模板一：纯文字 / Text Only

```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "标题里的<em>高亮词</em>",
  "subtitle": "日常 · 随笔",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "第一段，随便写什么。",
    "第二段，继续写。",
    "<section-break>中间分隔线的标题</section-break>",
    "分隔线后面的内容。"
  ]
},
```

**English version:**
```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "Title with <em>Highlight</em>",
  "subtitle": "Life · Essay",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "First paragraph, write whatever you want.",
    "Second paragraph, keep going.",
    "<section-break>Section Break Title</section-break>",
    "Content after the section break."
  ]
},
```

---

## ✦ 模板二：文字 + 图片 / Text + Image

```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "标题里的<em>高亮词</em>",
  "subtitle": "日常 · 摄影",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "图片前面的文字，介绍一下背景或者随便说说。",
    "还可以多写一段，不限制段数。",
    "<img src=\"images/你的图片文件名.jpg\" style=\"width:100%;border-radius:10px;margin:14px 0;\">",
    "图片后面还可以继续写，或者不写直接结束也行。"
  ]
},
```

**English version:**
```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "Title with <em>Highlight</em>",
  "subtitle": "Daily · Photography",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "Text before the image — set the scene or just say something.",
    "Another paragraph, no limit on how many you add.",
    "<img src=\"images/your-image-filename.jpg\" style=\"width:100%;border-radius:10px;margin:14px 0;\">",
    "Text after the image — optional, can be left out."
  ]
},
```

> 📁 图片文件放进 `images/` 文件夹，`src` 里的文件名要完全对应，包括大小写和扩展名（`.jpg` `.png` `.webp` 都可以）。

---

## ✦ 模板三：文字 + 视频 / Text + Video

```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "标题里的<em>高亮词</em>",
  "subtitle": "日常 · 视频",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "视频前面的文字，随便写。",
    "<video controls poster=\"images/封面图.jpg\" style=\"width:100%;border-radius:10px;margin:14px 0;max-height:70vh\"><source src=\"images/你的视频.mp4\" type=\"video/mp4\"></video>",
    "视频后面还可以继续写文字，或者留空。"
  ]
},
```

**English version:**
```json
{
  "id": "my-post-07",
  "num": "07",
  "date": "2026 · 3 · 26",
  "title": "Title with <em>Highlight</em>",
  "subtitle": "Daily · Video",
  "commentId": "post6",
  "nextId": null,
  "body": [
    "Text before the video — anything you want to say.",
    "<video controls poster=\"images/cover.jpg\" style=\"width:100%;border-radius:10px;margin:14px 0;max-height:70vh\"><source src=\"images/your-video.mp4\" type=\"video/mp4\"></video>",
    "Text after the video — optional."
  ]
},
```

> 📁 视频和封面图都放进 `images/` 文件夹。
> `poster` 是视频加载前显示的封面图，不需要的话把 `poster="images/封面图.jpg"` 整段删掉就行。

---

## ✦ 字段说明 / Field Reference

| 字段 | 说明 | 示例 |
|---|---|---|
| `id` | 文章唯一ID，只用英文/数字/横杠，不能重复 | `"rome-trip"` |
| `num` | 显示编号，纯展示用，不影响排序 | `"07"` |
| `date` | 日期，格式随意 | `"2026 · 3 · 26"` |
| `title` | 标题，用 `<em>词</em>` 包住想高亮的字 | `"在<em>罗马</em>的一天"` |
| `subtitle` | 副标题/分类标签 | `"Travel · Italy"` |
| `commentId` | 评论区ID，每篇不同，依次递增 | `"post6"` |
| `nextId` | 文章末尾"下一篇"链接，没有就写 `null` | `null` |
| `body` | 正文内容，每个字符串是一段 | 见上方模板 |

---

## ✦ body 里可以放的东西 / What goes inside body

```
纯文字段落        →  "随便写的文字内容"
图片             →  "<img src=\"images/文件名.jpg\" style=\"width:100%;border-radius:10px;margin:14px 0;\">"
视频             →  "<video controls ...><source src=\"images/文件名.mp4\" type=\"video/mp4\"></video>"
分隔线+小标题     →  "<section-break>这里写小标题</section-break>"
带链接的文字      →  "看这个 <a href=\"https://网址\" target=\"_blank\" style=\"color:var(--gold);border-bottom:1px solid var(--gold-d)\">链接文字</a>"
```

---

## ✦ 粘贴后结构示意 / Structure after pasting

```json
[
  {                        ← ✅ 新文章加在最前面（最新的排最上面）
    "id": "my-post-07",
    "num": "07",
    ...
  },                       ← ✅ 记得这里有逗号
  {                        ← 原来的第一篇
    "id": "addiction",
    "num": "01",
    ...
  },
  ...
]
```

---

## ✦ 常见错误 / Common Mistakes

- ❌ 忘记在新文章末尾 `}` 后面加 `,`
- ❌ `id` 和已有文章重复
- ❌ `commentId` 和已有文章重复
- ❌ 图片/视频文件名大小写不对（`Cat.jpg` ≠ `cat.jpg`）
- ❌ `body` 里每段之间忘记加 `,`
