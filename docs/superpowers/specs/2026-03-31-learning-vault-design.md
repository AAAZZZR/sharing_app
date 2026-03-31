# Learning Vault — 個人學習資料庫 App 設計文件

## 概述

一個 Flutter 跨平台 app（Android + iOS），讓用戶從社群平台（Instagram、Facebook、YouTube、TikTok/抖音）透過原生分享選單將內容儲存到個人學習資料庫。App 自動擷取 metadata 並透過 AI 生成摘要，用戶可加筆記和標籤來整理內容。

**主要目的**：練習 Flutter 開發 + 打造個人學習工具。

## 架構：全本地（方案 A）

所有處理在手機端完成，不需要後端伺服器。

```
社群 App → Share Intent (URL) → Flutter App
  → Metadata Extractor（HTTP 抓 og: 標籤）
  → AI Summarizer（直接呼叫 OpenAI / Claude API）
  → Local DB（SQLite）
  → UI Layer
```

### 五個核心模組

| 模組 | 職責 |
|------|------|
| Share Intent Handler | 接收其他 app 分享的 URL，辨識來源平台 |
| Metadata Extractor | HTTP 請求抓取 HTML `<meta og:*>` 標籤（標題、縮圖、描述） |
| AI Summarizer | 抽象層，統一介面支援 OpenAI / Claude，可在設定中切換 |
| Local DB | SQLite 儲存所有內容、筆記、標籤 |
| UI Layer | 首頁時間軸、平台分類、標籤瀏覽、搜尋、內容詳情、設定頁 |

## 資料模型

### Content 表

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | INTEGER PK | 自動遞增 |
| url | TEXT NOT NULL | 原始連結 |
| platform | TEXT | 'instagram', 'facebook', 'youtube', 'tiktok' |
| title | TEXT | 內容標題 |
| thumbnail_url | TEXT | 縮圖 URL |
| description | TEXT | 原始描述 |
| ai_summary | TEXT | AI 生成的摘要（可為 null） |
| note | TEXT | 用戶的純文字筆記 |
| created_at | DATETIME | 建立時間 |
| updated_at | DATETIME | 更新時間 |

### Tag 表

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | INTEGER PK | 自動遞增 |
| name | TEXT UNIQUE | 標籤名稱 |

### ContentTag 表（多對多關聯）

| 欄位 | 型別 | 說明 |
|------|------|------|
| content_id | INTEGER FK | 關聯 Content |
| tag_id | INTEGER FK | 關聯 Tag |

### 設計決策

- 筆記直接放在 Content 上（一則內容 = 一則筆記），不另開 Note 表
- platform 用字串存而非 enum，之後加新平台不用改 schema
- ai_summary 可為 null，擷取失敗或 AI 未處理完時先存其他資料

## 平台辨識

根據分享 URL 的 domain 辨識來源平台：

| 平台 | 辨識 domain |
|------|-------------|
| YouTube | youtube.com, youtu.be |
| Instagram | instagram.com |
| Facebook | facebook.com, fb.com, fb.watch |
| TikTok | tiktok.com |
| 抖音 | douyin.com |

未辨識的 domain 標記為 'other'。

## Metadata 擷取策略

1. 對 URL 發 HTTP GET 請求
2. 解析 HTML，擷取 Open Graph 標籤：`og:title`、`og:image`、`og:description`
3. 若 og 標籤缺失，嘗試 `<title>` 和 `<meta name="description">`
4. 若完全抓不到，保留 URL，讓 AI 或用戶手動補充

## AI 摘要

### 抽象層設計

統一介面 `AiService`，包含方法 `summarize(String content) → String`。

具體實作：
- `OpenAiService`：呼叫 OpenAI Chat Completions API
- `ClaudeService`：呼叫 Anthropic Messages API

用戶在設定頁選擇使用哪個 provider，並輸入對應的 API key。API key 使用 flutter_secure_storage 加密儲存。

### 摘要輸入

將擷取到的 metadata（標題 + 描述 + URL）作為 context 傳給 AI，請求生成重點摘要。

## UI 畫面

### 1. 首頁（時間軸）

- 所有內容按 created_at 降序排列
- 頂部：平台篩選 chips（全部 / Instagram / YouTube / Facebook / TikTok）
- 每張卡片：縮圖 + 平台標示 + 標題 + 摘要預覽 + 標籤
- 底部導航列：首頁、標籤、搜尋、設定

### 2. 內容詳情頁

- 頂部：返回按鈕 + 「開啟原文」按鈕（跳轉原始 URL）
- 縮圖大圖
- 平台 + 日期
- 標題
- 原始描述
- AI 摘要區塊
- 筆記編輯區塊（純文字）
- 標籤管理（現有標籤 + 新增標籤按鈕）

### 3. 標籤瀏覽頁

- Tag cloud 呈現，每個標籤顯示內容數量
- 點選標籤展開該標籤下的內容列表

### 4. 搜尋頁

- 搜尋框，即時顯示結果
- 搜尋範圍：標題 + AI 摘要 + 筆記內容 + 標籤名稱
- 使用 SQLite FTS 實現全文搜尋

### 5. 分享接收頁

- 從其他 app 分享進來時顯示
- 顯示 URL 和處理進度（平台辨識 → metadata 擷取 → AI 摘要生成）
- 可即時加筆記和標籤
- 儲存按鈕

### 6. 設定頁

- AI provider 選擇（下拉選單）
- API key 管理（各 provider 獨立設定）
- 儲存統計（已儲存內容數量）
- 資料匯出（JSON 格式）

## 技術選型

| 需求 | 套件 |
|------|------|
| 本地資料庫 | sqflite / drift |
| Share Intent 接收 | receive_sharing_intent |
| HTTP 請求 | http / dio |
| HTML 解析 | html（dart 套件） |
| 安全儲存 API key | flutter_secure_storage |
| URL launcher | url_launcher |
| 狀態管理 | Riverpod（型別安全、現代化、適合練習） |

## 儲存策略

- 先本地（SQLite），之後再考慮雲端同步
- 之後加雲端不影響現有架構，只需加 sync layer

## 範圍外（不做）

- 雲端同步（第一版不做）
- 影片下載或離線播放
- 社群平台 OAuth 登入
- 多語言 i18n
