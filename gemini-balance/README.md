以下是使用繁體中文用語修改後的 README.md 文件：

```markdown:gemini-balance/README.md
# Gemini Balance Docker 環境

這個目錄包含用於部署 Gemini Balance 的 Docker 配置，提供 Google Gemini API 的代理服務，支援多種模型、串流輸出、使用者管理和使用量控制。

## 功能特點

- 使用官方 ghcr.io/snailyp/gemini-balance 映像
- 支援 Google Gemini 所有模型（包括 gemini-2.5-pro, gemini-2.5-flash 等）
- 提供 API 金鑰管理和輪換功能
- 支援串流輸出和思考過程顯示
- 內建 MySQL 資料庫用於使用者和使用量管理
- 與 nginx-proxy 整合，實現虛擬主機路由

## 系統需求

- Docker 和 Docker Compose
- 有效的 Google Gemini API 金鑰
- 至少 2GB 可用記憶體
- 與 nginx-proxy 共享網路（可選，用於虛擬主機路由）

## 快速開始

### 環境設置

本專案使用 `.env` 檔案儲存配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 檔案並重命名為 `.env`（如果沒有 .env.example，可以建立一個新的 .env 檔案）
   ```bash
   cp .env.example .env
   ```

2. 在 `.env` 檔案中設置您的 Google Gemini API 金鑰和其他配置
   ```
   API_KEYS=["your-api-key-1","your-api-key-2"]
   ALLOWED_TOKENS=["sk-thinksoft"]
   AUTH_TOKEN=sk-thinksoft
   ```

3. 確保 `.env` 檔案不會被提交到版本控制系統中

### 啟動服務

在此目錄下執行以下命令啟動 Gemini Balance：

```bash
docker-compose up -d
```

### 停止服務

```bash
docker-compose down
```

## 使用方法

### 存取網頁介面

啟動服務後，可以通過以下方式存取網頁介面：

- 使用虛擬主機：http://gemini.localhost（需要 nginx-proxy 支援）
- 直接存取連接埠：http://localhost:8186

### API 使用

Gemini Balance 提供與 OpenAI API 相容的介面，可以通過以下方式使用：

```bash
curl http://gemini.localhost/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-thinksoft" \
  -d '{
    "model": "gemini-2.5-pro",
    "messages": [{"role": "user", "content": "你好，請介紹一下自己"}],
    "stream": true
  }'
```

### 支援的模型

Gemini Balance 支援所有 Google Gemini 模型，包括但不限於：

- gemini-2.5-pro
- gemini-2.5-flash
- gemini-2.5-flash-lite
- gemini-2.0-pro
- gemini-2.0-flash

## 配置說明

### 主要環境變數

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| API_KEYS | Google Gemini API 金鑰列表（JSON 陣列） | [] |
| ALLOWED_TOKENS | 允許存取的 API Token 列表（JSON 陣列） | [] |
| AUTH_TOKEN | 預設授權 Token | sk-thinksoft |
| VIRTUAL_HOST | 虛擬主機名稱 | gemini.localhost |
| PORT | 外部存取連接埠 | 8186 |
| MYSQL_HOST | MySQL 主機名 | gemini-balance-db |
| MYSQL_PORT | MySQL 連接埠 | 3306 |
| MYSQL_USER | MySQL 使用者名稱 | gemini |
| MYSQL_PASSWORD | MySQL 密碼 | gbpasswd |
| MYSQL_DATABASE | MySQL 資料庫名稱 | gemini_balance |

### 進階配置

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| URL_CONTEXT_ENABLED | 是否啟用網址上下文 | true |
| TOOLS_CODE_EXECUTION_ENABLED | 是否啟用程式碼執行工具 | true |
| SHOW_THINKING_PROCESS | 是否顯示思考過程 | true |
| STREAM_OPTIMIZER_ENABLED | 是否啟用串流最佳化 | false |
| SAFETY_SETTINGS | 安全設置（JSON 格式） | [...] |
| TTS_MODEL | 文字轉語音模型 | gemini-2.5-flash-preview-tts |
| LOG_LEVEL | 日誌級別 | info |

完整的配置選項請參考 `.env` 檔案。

## 目錄結構

- `~/docker-vols/gemini_balance/logs/`: 應用程式日誌目錄
- `~/docker-vols/gemini_balance/data/`: 應用程式資料目錄
- `~/docker-vols/db_data/gemini_balance/`: MySQL 資料目錄

## 與 Nginx Proxy 整合

Gemini Balance 可以與 Nginx Proxy 整合，實現虛擬主機路由。確保以下配置：

1. 在 `.env` 檔案中設置 `VIRTUAL_HOST=gemini.localhost`
2. 確保 docker-compose.yml 中包含正確的網路配置：
   ```yaml
   networks:
     default:
       external: true
       name: ${NETWORK_NAME:-nginx-proxy}
   ```
3. 確保 nginx-proxy 容器已經啟動並執行

## 常見問題

### 無法連接到資料庫

- 確認 MySQL 容器已正常啟動：`docker ps | grep gemini-balance-db`
- 檢查資料庫連接配置是否正確
- 查看 MySQL 日誌：`docker logs gemini-balance-db`

### API 請求失敗

- 確認 API_KEYS 配置正確且有效
- 檢查授權 Token 是否正確
- 查看應用程式日誌：`docker logs gemini-balance`

### 無法通過虛擬主機存取

- 確認 nginx-proxy 容器正常執行
- 確認 VIRTUAL_HOST 環境變數已正確設置
- 確認容器已連接到 nginx-proxy 網路
- 在 hosts 檔案中新增 `127.0.0.1 gemini.localhost`

## 備份與還原

### 備份資料庫

```bash
docker exec gemini-balance-db mysqldump -u root -p${MYSQL_ROOT_PASSWORD} gemini_balance > backup.sql
```

### 還原資料庫

```bash
cat backup.sql | docker exec -i gemini-balance-db mysql -u root -p${MYSQL_ROOT_PASSWORD} gemini_balance
```

## 更新

更新到最新版本：

```bash
docker-compose pull
docker-compose down
docker-compose up -d
```

## 授權

此 Docker 配置遵循 MIT 授權協議。Gemini Balance 專案由 snailyp 開發和維護。

## 相關資源

- [Gemini Balance GitHub 儲存庫](https://github.com/snailyp/gemini-balance)
- [Google Gemini API 文件](https://ai.google.dev/docs)
```