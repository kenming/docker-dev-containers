# Node.js 開發容器環境

這個目錄包含用於 Node.js 開發的 Docker 開發容器配置，特別適合與 VS Code 的 Remote Containers 擴展一起使用。

## 功能特點

- 基於 Node.js 18 官方映像
- 預先安裝了常用開發工具（git, curl, wget, zip 等）
- 配置了 sudo 權限，方便開發過程中的系統操作
- 與 VS Code 開發容器無縫集成
- 支援透過環境變數自定義配置

## 系統需求

- Docker 和 Docker Compose
- Visual Studio Code
- VS Code 的 Remote - Containers 擴展

## 快速開始

### 環境設置

本專案使用 `.env` 文件存儲配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 文件並重命名為 `.env`
   ```bash
   cp .env.example .env
   ```

2. 根據需要在 `.env` 文件中調整配置值

3. 確保 `.env` 文件不會被提交到版本控制系統中

### 使用 VS Code 開發容器

1. 在 VS Code 中安裝 "Remote - Containers" 擴展
2. 在 VS Code 中打開此目錄
3. 按下 F1 或 Ctrl+Shift+P，然後輸入並選擇 "Remote-Containers: Reopen in Container"
4. 等待容器建立和配置完成

### 手動啟動容器

如果您不使用 VS Code 的開發容器功能，也可以手動啟動容器：

```bash
docker-compose -f docker-compose.devcontainer.yml up -d
```

### 停止容器

```bash
docker-compose -f docker-compose.devcontainer.yml down
```

## 目錄結構

容器內的主要目錄：

- `/home/node-dev` - 主要開發目錄（映射自主機的 `~/docker/node-dev`）
- `/home/projects` - 專案目錄（映射自主機的 `~/projects`）
- `/var/www/html` - Web 目錄（映射自主機的 `~/docker-vols/sites/devwp`）

## 環境變數說明

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| CONTAINER_NAME | 容器名稱 | dev-node |
| NODE_PORT | Node.js 應用程式端口 | 3000 |
| HOST_WWW_DIR | 主機上的 Web 目錄 | ~/docker-vols/sites/devwp |
| HOST_DEV_DIR | 主機上的開發目錄 | ~/docker/node-dev |
| HOST_PROJECTS_DIR | 主機上的專案目錄 | ~/projects |
| NETWORK_NAME | Docker 網絡名稱 | nginx-proxy |

## 自定義容器

### 修改 Dockerfile

如果您需要安裝其他工具或修改 Node.js 版本，可以編輯 `Dockerfile`。例如，要安裝特定的 npm 包：

```dockerfile
# 安裝全局 npm 包
RUN npm install -g nodemon typescript ts-node
```

### 添加啟動腳本

您可以在 `.devcontainer` 目錄中修改或添加以下腳本：

- `post-create.sh` - 容器首次創建後執行
- `post-start.sh` - 容器每次啟動後執行

## 常見用例

### 運行 Node.js 應用程式

```bash
# 進入容器
docker exec -it dev-node bash

# 創建並運行簡單的 Node.js 應用
cd /home/node-dev
mkdir my-app && cd my-app
npm init -y
npm install express
echo 'const express = require("express"); const app = express(); app.get("/", (req, res) => res.send("Hello World!")); app.listen(3000, () => console.log("Server running on port 3000"));' > index.js
node index.js
```

然後在瀏覽器中訪問 http://localhost:3000

### 使用 npm 腳本

您可以在 `package.json` 中定義腳本，然後在容器中運行：

```json
{
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  }
}
```

```bash
npm run dev
```

## 故障排除

### 端口衝突

如果出現端口衝突，可以在 `.env` 文件中修改 `NODE_PORT` 變數。

### 權限問題

如果遇到文件權限問題，容器內的 `node` 用戶已配置了 sudo 權限，可以使用：

```bash
sudo chown -R node:node /path/to/directory
```

## 與其他服務集成

此開發環境已配置為使用名為 `nginx-proxy` 的外部網絡，可以輕鬆與其他 Docker 服務（如資料庫、代理服務器等）集成。

## 授權

此 Docker 配置遵循 MIT 授權協議。