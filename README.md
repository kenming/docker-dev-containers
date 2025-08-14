# Docker 環境集合

這個目錄包含多個 Docker 環境配置，用於不同的開發和部署需求。每個子目錄都是獨立的 Docker 環境，配有詳細的說明文檔。

## 目錄說明

- [`wordpress/`](wordpress/README.md): WordPress 開發環境
  - 包含 MySQL、WordPress 和 phpMyAdmin
  - 支援多個 WordPress 站點（blog 和 kenming）
  - [查看詳細說明](wordpress/README.md)

- [`sqlserver/`](sqlserver/README.md): Microsoft SQL Server 環境
  - 使用 SQL Server 2022 Express 版本
  - 包含 Adminer 資料庫管理工具
  - [查看詳細說明](sqlserver/README.md)

- [`node-dev/`](node-dev/README.md): Node.js 開發環境
  - 包含 Dockerfile 和 VS Code DevContainer 配置
  - 適合 Node.js 應用程式開發
  - [查看詳細說明](node-dev/README.md)

- [`nginx-proxy/`](nginx-proxy/README.md): Nginx 代理服務器
  - 用於反向代理和虛擬主機配置
  - 可用於連接其他 Docker 容器
  - [查看詳細說明](nginx-proxy/README.md)

- [`mongodb/`](mongodb/README.md): MongoDB 數據庫環境
  - 包含 MongoDB 和 Mongo Express 管理工具
  - 使用命名卷持久化數據
  - [查看詳細說明](mongodb/README.md)

- [`devwp/`](devwp/README.md): WordPress 插件開發容器環境
  - 包含 Dockerfile 和 VS Code DevContainer 配置
  - 適合 WordPress 主題和插件開發
  - 已配置 Xdebug 支持
  - [查看詳細說明](devwp/README.md)

- [`gemini-balance/`](gemini-balance/README.md): Google Gemini API 代理服務
  - 提供 Google Gemini API 的代理和負載平衡
  - 支援多種 Gemini 模型（包括 gemini-2.5-pro, gemini-2.5-flash 等）
  - 內建 MySQL 資料庫用於使用者和使用量管理
  - 與 nginx-proxy 整合，實現虛擬主機路由
  - [查看詳細說明](gemini-balance/README.md)

## 環境配置

本專案使用 Git 子模組來管理環境配置文件（.env），以確保敏感信息不會被提交到公開儲存庫中。

### 首次克隆設置

如果您是首次克隆此儲存庫，請按照以下步驟設置環境配置：

1. 使用 `--recursive` 選項克隆儲存庫，以同時克隆子模組：
   ```bash
   git clone --recursive https://github.com/yourusername/docker-dev-environments.git
   cd docker-dev-environments
   ```

2. 如果您已經克隆了儲存庫但沒有使用 `--recursive` 選項，可以使用以下命令初始化子模組：
   ```bash
   git submodule update --init --recursive
   ```

3. 運行設置腳本，創建環境變數文件的符號連結：
   ```bash
   chmod +x setenv.sh
   ./setenv.sh
   ```

### 訪問私有子模組

如果您沒有訪問私有 `env-configs` 儲存庫的權限，請聯繫儲存庫管理員獲取訪問權限，或者根據 `.env.example` 文件創建您自己的 `.env` 文件。

### 更新環境配置

當環境配置有更新時，您可以使用以下命令更新子模組：

```bash
git submodule update --remote
./setenv.sh
```

## 快速開始

每個環境都有自己的配置和使用方法，請參閱各自的 README.md 文件。設置好環境配置後，您可以按照以下步驟啟動環境：

1. 進入相應的目錄
   ```bash
   cd 環境目錄名稱
   ```

2. 啟動環境
   ```bash
   docker-compose up -d
   ```

## 共享網絡

大多數環境都配置為使用名為 `nginx-proxy` 的外部網絡，這使得它們可以相互通信。如果該網絡尚未創建，請運行：

```bash
docker network create nginx-proxy
```

## 安全性建議

1. **修改默認密碼**：在生產環境中，請務必修改所有默認密碼
2. **定期更新映像**：定期更新 Docker 映像以獲取安全補丁
3. **限制訪問**：根據需要限制容器的網絡訪問
4. **保護環境配置**：確保 `env-configs` 儲存庫保持私有

## 貢獻

歡迎提交 Pull Requests 和 Issues 來改進這些 Docker 環境。在提交前，請確保：

1. 遵循現有的文件結構和命名約定
2. 不要在提交中包含敏感信息或實際密碼
3. 更新相關的 README.md 文件

## 授權

此 Docker 配置集合遵循 MIT 授權協議。