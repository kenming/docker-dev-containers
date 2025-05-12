# WordPress 開發容器 (DevWP)

這個專案提供了一個完整的 WordPress 開發環境，使用 Docker 和 VS Code 的 Remote Containers 擴展來創建一個隔離且一致的開發環境。

## 功能特點

- 基於 WordPress PHP 8.3 官方映像
- 包含 MySQL 5.7.44 資料庫
- 整合 Adminer 資料庫管理工具
- 預設安裝 Xdebug 用於 PHP 除錯
- 預設安裝 WP-CLI 用於 WordPress 命令行管理
- 使用 nginx-proxy 網絡實現多站點開發
- 完整的 VS Code 開發環境配置，包含常用擴展

## 系統需求

- Docker 和 Docker Compose
- Visual Studio Code
- VS Code 的 Remote - Containers 擴展

## 快速開始

### 1. 複製專案

```bash
git clone <repository-url> wordpress-dev
cd wordpress-dev
```

### 2. 啟動開發容器

在 VS Code 中打開專案資料夾，然後：

1. 按下 F1 或 Ctrl+Shift+P
2. 輸入並選擇 "Remote-Containers: Reopen in Container"
3. 等待容器建立和配置完成

### 3. 訪問 WordPress

- WordPress 站點：http://devwp.localhost
- Adminer 資料庫管理：http://adminer.devwp.localhost

### 4. 資料庫連接資訊

- 資料庫：wp_devwp
- 使用者：wpuser
- 密碼：wppasswd
- 主機：mysql_devwp:3306 (容器內) 或 localhost:3306 (主機上)

## 目錄結構

```
/home/devwp           # 主要開發目錄
/var/www/html         # WordPress 安裝目錄
/home/projects        # 專案目錄 (掛載自主機)
```

## 開發工具

### 常用命令

- `wpdir` - 快速進入 WordPress 安裝目錄
- `devdir` - 快速進入開發目錄

### WP-CLI

WP-CLI 已預先安裝，可以使用以下命令：

```bash
# 列出已安裝的外掛
wp plugin list

# 安裝一個外掛
wp plugin install <plugin-name> --activate

# 更新 WordPress 核心
wp core update
```

### Xdebug

Xdebug 已配置為與 VS Code 協同工作。要開始除錯：

1. 在 VS Code 中切換到除錯視圖
2. 選擇 "Listen for Xdebug" 配置
3. 按下綠色的開始按鈕
4. 在瀏覽器中訪問您的 WordPress 站點

## 自訂

### 添加新外掛或主題

將外掛或主題放置在以下目錄：

- 外掛：`/var/www/html/wp-content/plugins/`
- 主題：`/var/www/html/wp-content/themes/`

### 修改 PHP 配置

PHP 配置文件位於 `/usr/local/etc/php/conf.d/` 目錄中。

## 故障排除

### 權限問題

如果遇到文件權限問題，可以運行以下命令：

```bash
sudo chown -R www-data:www-data /var/www/html
```

### 容器無法啟動

檢查端口衝突：

```bash
docker ps -a
```

確保 nginx-proxy 網絡已存在：

```bash
docker network ls
```

如果不存在，創建它：

```bash
docker network create nginx-proxy
```

## 貢獻

歡迎提交 Pull Requests 和 Issues 來改進這個開發環境。

## 授權

[MIT License](LICENSE)