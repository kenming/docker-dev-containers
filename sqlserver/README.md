# SQL Server Docker 開發環境

這個目錄包含用於快速部署 Microsoft SQL Server 開發環境的 Docker 配置。

## 功能特點

- 使用最新的 SQL Server 2022 (Express 版本)
- 包含 Adminer 資料庫管理工具，方便進行資料庫操作
- 使用命名卷持久化資料庫數據
- 支援透過環境變數自定義配置

## 系統需求

- Docker 和 Docker Compose
- 至少 2GB 可用記憶體 (SQL Server 最低要求)

## 快速開始

### 環境設置

本專案使用 `.env` 文件存儲敏感信息和配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 文件並重命名為 `.env`
   ```bash
   cp .env.example .env
   ```

2. 在 `.env` 文件中填入您的實際配置值，尤其是密碼
   ```
   MSSQL_SA_PASSWORD=your_strong_password_here
   ADMINER_DEFAULT_PASSWORD=your_strong_password_here
   ```

3. 確保 `.env` 文件不會被提交到版本控制系統中

### 啟動服務

在此目錄下運行以下命令啟動 SQL Server 和 Adminer：

```bash
docker-compose up -d
```

### 停止服務

```bash
docker-compose down
```

如果您想同時刪除數據卷（會刪除所有資料庫數據）：

```bash
docker-compose down -v
```

## 連接到 SQL Server

### 使用 Adminer

1. 在瀏覽器中訪問 http://localhost:8080 (或您在 .env 中設定的端口)
2. 使用以下信息登入：
   - 系統: MS SQL
   - 伺服器: sqlserver
   - 使用者: sa
   - 密碼: (您在 .env 文件中設置的 MSSQL_SA_PASSWORD)
   - 資料庫: (留空或輸入特定資料庫名稱)

### 使用 SQL Server Management Studio 或其他工具

- 伺服器: localhost,14360 (或您在 .env 中設定的端口)
- 驗證: SQL Server 驗證
- 使用者: sa
- 密碼: (您在 .env 文件中設置的 MSSQL_SA_PASSWORD)

## 環境變數說明

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| ACCEPT_EULA | 接受 SQL Server 使用條款 | Y |
| MSSQL_SA_PASSWORD | SA 使用者密碼 | (需自行設定) |
| MSSQL_PID | SQL Server 版本 | Express |
| SQL_PORT | SQL Server 連接埠 | 14360 |
| ADMINER_PORT | Adminer 連接埠 | 8080 |
| ADMINER_DEFAULT_SERVER | Adminer 預設伺服器 | sqlserver |
| ADMINER_DESIGN | Adminer 介面主題 | pappu687 |
| ADMINER_DEFAULT_USER | Adminer 預設使用者 | sa |
| ADMINER_DEFAULT_PASSWORD | Adminer 預設密碼 | (需自行設定) |

## 資料持久化

資料庫數據存儲在名為 `sqlserver-data` 的 Docker 命名卷中。這確保了容器重啟後數據不會丟失。

如果您想使用主機目錄而非命名卷，可以在 `docker-compose.yml` 中取消註解並修改以下行：

```yaml
# - ~/docker-vols/mssql:/var/opt/mssql  # 持久化資料
```

## 初始化腳本 (可選)

如果您需要在容器首次啟動時執行 SQL 腳本，可以：

1. 創建 `init-scripts` 目錄
2. 將 `.sql` 文件放入該目錄
3. 在 `docker-compose.yml` 中取消註解以下行：

```yaml
# - ./init-scripts:/docker-entrypoint-initdb.d  # 初始化腳本
```

## 常見問題

### SQL Server 無法啟動

- 檢查分配給 Docker 的記憶體是否至少有 2GB
- 確認 SA 密碼符合 SQL Server 密碼複雜度要求 (至少 8 個字元，包含大小寫字母、數字和符號)

### 連接被拒絕

- 確認使用的是正確的端口 (預設為 14360)
- 檢查防火牆設置是否允許該端口的連接

## 授權

此 Docker 配置遵循 MIT 授權協議。

SQL Server 使用受 Microsoft 授權條款約束，使用前請確保您了解並同意這些條款。