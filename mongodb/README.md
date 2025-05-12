# MongoDB Docker 開發環境

這個目錄包含用於快速部署 MongoDB 資料庫和 Mongo Express 管理界面的 Docker 配置。

## 功能特點

- 使用 MongoDB 8.0.6 官方映像
- 包含 Mongo Express 網頁管理界面
- 使用命名卷持久化資料
- 支援透過環境變數自定義配置
- 與 nginx-proxy 網絡集成

## 系統需求

- Docker 和 Docker Compose
- nginx-proxy 網絡 (如果尚未創建，請參考下方說明)

## 快速開始

### 環境設置

本專案使用 `.env` 文件存儲敏感信息和配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 文件並重命名為 `.env`
   ```bash
   cp .env.example .env
   ```

2. 在 `.env` 文件中填入您的實際配置值，特別是密碼
   ```
   MONGO_ROOT_PASSWORD=your_secure_password_here
   ```

3. 確保 `.env` 文件不會被提交到版本控制系統中

### 啟動服務

在此目錄下運行以下命令啟動 MongoDB 和 Mongo Express：

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

## 訪問 MongoDB

### 使用 Mongo Express

1. 在瀏覽器中訪問 http://localhost:8081 (或您在 .env 中設定的端口)
2. 無需登入即可使用界面 (除非您啟用了基本認證)

### 使用 MongoDB 客戶端

```bash
# 使用 docker exec
docker exec -it mongodb mongosh -u root -p password --authenticationDatabase admin

# 或使用 MongoDB 客戶端
mongosh mongodb://root:password@localhost:27017/admin
```

### 使用應用程式連接

連接字符串格式：
```
mongodb://root:password@localhost:27017/admin
```

## 環境變數說明

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| MONGO_CONTAINER_NAME | MongoDB 容器名稱 | mongodb |
| MONGO_PORT | MongoDB 連接埠 | 27017 |
| MONGO_ROOT_USERNAME | MongoDB 管理員用戶名 | root |
| MONGO_ROOT_PASSWORD | MongoDB 管理員密碼 | password (請修改) |
| MONGO_EXPRESS_CONTAINER_NAME | Mongo Express 容器名稱 | mongo-express |
| MONGO_EXPRESS_PORT | Mongo Express 連接埠 | 8081 |
| MONGO_EXPRESS_BASICAUTH | 是否啟用基本認證 | false |
| MONGO_EXPRESS_BASICAUTH_USERNAME | 基本認證用戶名 | admin |
| MONGO_EXPRESS_BASICAUTH_PASSWORD | 基本認證密碼 | pass |
| NETWORK_NAME | Docker 網絡名稱 | nginx-proxy |

## 資料持久化

資料庫數據存儲在兩個 Docker 命名卷中：
- `mongo-data`: 存儲資料庫數據
- `mongo-config`: 存儲資料庫配置

這確保了容器重啟後數據不會丟失。

## 安全性注意事項

1. **修改默認密碼**: 在生產環境中，請務必修改默認的 root 密碼
2. **啟用基本認證**: 在公開環境中，建議啟用 Mongo Express 的基本認證
3. **限制網絡訪問**: 考慮限制 MongoDB 端口的訪問，只允許應用服務器連接

## 常見問題

### MongoDB 無法啟動

- 檢查端口是否被占用
- 確認 Docker 有足夠的資源（內存、磁盤空間）

### 無法連接到 MongoDB

- 確認使用的是正確的端口和憑證
- 檢查防火牆設置是否允許該端口的連接

### 創建 nginx-proxy 網絡

如果 nginx-proxy 網絡尚未創建，請運行：

```bash
docker network create nginx-proxy
```

## 授權

此 Docker 配置遵循 MIT 授權協議。