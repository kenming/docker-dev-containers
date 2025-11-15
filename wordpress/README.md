# WordPress Docker 環境

這個目錄包含用於快速部署多個 WordPress 網站的 Docker 配置，包括 MySQL 資料庫和 phpMyAdmin 管理界面。

**此設定檔已更新**，整合了 `nginx-proxy`、`mkcert` 與客製化 `Dockerfile`，以**完整解決**在本地 SSL (HTTPS) 環境下 `wp_remote_post` 請求失敗的問題。

## 功能特點

- 使用 WordPress PHP 8.3 官方映像
- 使用 MySQL 5.7.44 作為資料庫
- 包含 phpMyAdmin 5.2.1 管理界面
- 支援多個 WordPress 站點（blog 和 kenming）
- 使用 nginx-proxy 實現虛擬主機功能
- 完整本地 HTTPS
- 支援透過環境變數自定義配置
- 持久化存儲所有數據

## 系統需求

- Docker 和 Docker Compose
- nginx-proxy 網絡（如果尚未創建，請參考下方說明）
- **本地憑證生成工具** (如 `mkcert`)，用於 HTTPS 開發環境。

## 快速開始

### 環境設置

本專案使用 `.env` 文件存儲敏感信息和配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 文件並重命名為 `.env`

   ```bash
   cp .env.example .env
   ```

2. 在 `.env` 文件中填入您的實際配置值，特別是密碼

   ```
   MYSQL_PASSWORD=your_secure_password_here
   MYSQL_ROOT_PASSWORD=your_secure_root_password_here
   ```

3. 確保 `.env` 文件不會被提交到版本控制系統中

### 啟動服務

在此目錄下運行以下命令啟動所有服務：

```bash
docker-compose up -d
```

### 停止服務

```bash
docker-compose down
```

## 🔒 HTTPS 與憑證設置（開發環境專用）

這是本環境的核心設定。請**嚴格依照**以下步驟操作，以確保 `wp_remote_post` 在 SSL 環境下能正常運作。

### 步驟 1：(關鍵) 棄用 `.localhost`，改用 `.test`

*   **原因**：根據 [RFC 6761](https://datatracker.ietf.org/doc/html/rfc6761) 規範，`.localhost` **必須**被強制解析為 `127.0.0.1`。這會導致 WordPress 容器內的 `wp_remote_post` 請求**忽略 `/etc/hosts`**，試圖連接**容器自己**的 443 埠，最終導致 `(7) Connection refused` 錯誤。
*   **解決**：本設定**全面使用 `.test`** 網域 (例如 `kenming.test`)，此網域沒有強制解析問題。

### 步驟 2：Host 檔案設定 (Windows + WSL)

您必須同時設定 Windows 和 WSL 的 `hosts` 檔案。

1.  **Windows Host 檔案** (`C:\Windows\System32\drivers\etc\hosts`) (以系統管理員身分編輯)

   ```
   127.0.0.1 blog.test kenming.test phpmyadmin.test images.kenming.idv.tw
   ```

2.  **WSL Host 檔案** (`/etc/hosts`)

   ```bash
   sudo nano /etc/hosts
   ```

   (加入與 Windows 相同的內容)

   ```
   127.0.0.1 blog.test kenming.test phpmyadmin.test images.kenming.idv.tw
   ```

### 步驟 3：生成 `mkcert` 憑證 (並正確命名)

1.  **安裝 `mkcert` Root CA** (僅需執行一次)

   ```bash
   mkcert -install
   ```

2.  **生成憑證** `cd` 到 `nginx-proxy` 的證書目錄 (例如 `~/docker-vols/nginx/certs`)：

   ```bash
   cd ~/docker-vols/nginx/certs
   mkcert kenming.test blog.test phpmyadmin.test images.kenming.idv.tw
   ```

3.  **\[關鍵\] 複製並改名** `nginx-proxy` 依賴嚴格的檔案命名 (`domain.test.crt` / `domain.test.key`)。 (假設 `mkcert` 產生了 `kenming.test+3.pem` 和 `kenming.test+3-key.pem`)

   ```bash
   # 複製 .pem (證書) 檔案為 .crt 檔案
   cp kenming.test+3.pem kenming.test.crt
   cp kenming.test+3.pem blog.test.crt
   cp kenming.test+3.pem phpmyadmin.test.crt
   cp kenming.test+3.pem images.kenming.idv.tw.crt
   
   # 複製 -key.pem (私鑰) 檔案為 .key 檔案
   cp kenming.test+3-key.pem kenming.test.key
   cp kenming.test+3-key.pem blog.test.key
   cp kenming.test+3-key.pem phpmyadmin.test.key
   cp kenming.test+3-key.pem images.kenming.idv.tw.key
   ```

### 步驟 4：同步 Root CA (解決 `(60) SSL problem`)

1.  將 `mkcert` 的根證書 (Root CA) 複製到 `wp-base` 目錄下：

   ```bash
   # 確保您在 wordpress 專案目錄下
   cp ~/.local/share/mkcert/rootCA.pem ./wp-base/mkcert-rootCA.pem
   ```

2.  `wp-base/Dockerfile` (已在 `docker-compose.yml` 中由 `wordprss_kenming` 服務的 `build:` 指令指定) 將在建置時自動讀取此檔案並將其安裝到映像檔中，讓容器信任此 CA。

### 步驟 5：檢查 `docker-compose.yml` (解決 `(7) Connection refused`)

確保 `wordprss_kenming` (以及其他需要自我請求的) 服務包含 `extra_hosts` 設定。這會強制容器將 `kenming.test` 解析為主機 IP (`host-gateway`)，而不是 `127.0.0.1`。

```yaml
wordprss_kenming:
  build:
    context: ./wp-base  # <-- (解決 SSL 信任問題)
    # ...
  environment:
    - VIRTUAL_HOST=${WP_KENMING_VIRTUAL_HOST:-kenming.test}
    # ...
  extra_hosts:
    - "kenming.test:host-gateway" # <-- (解決 DNS/Connection Refused 問題)
```

### 步驟 6：啟動服務與更新資料庫

1.  執行「快速開始」中的「啟動服務」步驟 (包含 `build --no-cache`)。
2.  **\[關鍵\] 更新 WordPress 資料庫**
    *   登入 `https://phpmyadmin.test`。
    *   進入 `wp_kenming` 資料庫 (或 `wp_blog`)。
    *   打開 `wp_options` 資料表。
    *   將 `option_name` 為 **`siteurl`** 和 **`home`** 的 `option_value` 欄位，更新為 `https://kenming.test` (或 `https://blog.test`)。

## 訪問網站和管理工具

### WordPress 網站

*   Blog 網站：`https://blog.test`
*   Kenming 網站：`https://kenming.test`
*   圖片伺服器：`https://images.kenming.idv.tw`

### phpMyAdmin

*   管理界面：`https://phpmyadmin.test`
*   使用者：root
*   密碼：(您在 .env 文件中設置的 `MYSQL_ROOT_PASSWORD`)

## 環境變數說明

### MySQL 設定

| 變數名稱 | 說明 | 預設值 |
| --- | --- | --- |
| MYSQL_CONTAINER_NAME | MySQL 容器名稱 | wordpress_db |
| MYSQL_VERSION | MySQL 版本 | 5.7.44 |
| MYSQL_DATABASE | 默認資料庫名稱 | wp_blog |
| MYSQL_USER | MySQL 使用者名稱 | wpuser |
| MYSQL_PASSWORD | MySQL 使用者密碼 | wppasswd |
| MYSQL_ROOT_PASSWORD | MySQL root 密碼 | dbpasswd |
| MYSQL_DATA_DIR | MySQL 資料目錄 | ~/docker-vols/db_data/mysql |

### phpMyAdmin 設定

| 變數名稱 | 說明 | 預設值 |
| --- | --- | --- |
| PMA_CONTAINER_NAME | phpMyAdmin 容器名稱 | phpmyadmin |
| PMA_VERSION | phpMyAdmin 版本 | 5.2.1 |
| PMA_VIRTUAL_HOST | phpMyAdmin 虛擬主機名稱 | phpmyadmin.test |
| PMA_UPLOAD_LIMIT | 上傳檔案大小限制 | 500M |

### WordPress Blog 設定

| 變數名稱 | 說明 | 預設值 |
| --- | --- | --- |
| WP_BLOG_CONTAINER_NAME | Blog 容器名稱 | wordpress_blog |
| WP_BLOG_VERSION | WordPress 版本 | php8.3 |
| WP_BLOG_VIRTUAL_HOST | Blog 虛擬主機名稱 | blog.test |
| WP_BLOG_DB_NAME | Blog 資料庫名稱 | wp_blog |
| WP_BLOG_DIR | Blog 檔案目錄 | ~/docker-vols/sites/blog |
| WP_BLOG_DEBUG | 是否啟用除錯模式 | 未設置 |

### WordPress Kenming 設定

| 變數名稱 | 說明 | 預設值 |
| --- | --- | --- |
| WP_KENMING_CONTAINER_NAME | Kenming 容器名稱 | wordpress_kenming |
| WP_KENMING_VERSION | WordPress 版本 | php8.3 |
| WP_KENMING_VIRTUAL_HOST | Kenming 虛擬主機名稱 | kenming.test |
| WP_KENMING_DB_NAME | Kenming 資料庫名稱 | wp_kenming |
| WP_KENMING_DIR | Kenming 檔案目錄 | ~/docker-vols/sites/kenming |
| WP_KENMING_DEBUG | 是否啟用除錯模式 | 未設置 |

### 圖片伺服器設定

| 變數名稱 | 說明 | 預設值 |
| --- | --- | --- |
| IMAGE_SERVER_CONTAINER_NAME | 圖片伺服器容器名稱 | image_kenming |
| IMAGE_DIR | 圖片伺服器的本機檔案目錄 | ~/docker-vols/sites/image_kenming |

## 目錄結構 (更新)

- `~/docker-vols/sites/blog/`: Blog WordPress 網站檔案
- `~/docker-vols/sites/kenming/`: Kenming WordPress 網站檔案
- **`~/docker-vols/sites/image_kenming/`:** **靜態圖片伺服器檔案**
- `~/docker-vols/db_data/mysql/`: MySQL 資料庫檔案

## 添加新的 WordPress 網站

若要添加新的 WordPress 網站，請按照以下步驟：

1. 在 `.env` 文件中添加新站點的配置 (使用 `.test` 網域)：

   ```bash
   WP_NEWSITE_CONTAINER_NAME=wordpress_newsite
   WP_NEWSITE_VERSION=php8.3
   WP_NEWSITE_VIRTUAL_HOST=newsite.test
   WP_NEWSITE_DB_NAME=wp_newsite
   WP_NEWSITE_DIR=~/docker-vols/sites/newsite
   ```

2. 在 `docker-compose.yml` 文件中添加新的服務配置。**\[重要\]** 記得加上 `extra_hosts`：

   ```yaml
   wordprss_newsite:
     image: wordpress:${WP_NEWSITE_VERSION:-php8.3}
     container_name: ${WP_NEWSITE_CONTAINER_NAME:-wordpress_newsite}
     restart: always
     environment:
       - VIRTUAL_HOST=${WP_NEWSITE_VIRTUAL_HOST:-newsite.test}
       - WORDPRESS_DB_NAME=${WP_NEWSITE_DB_NAME:-wp_newsite}
       - WORDPRESS_DB_HOST=mysql_server:3306
       - WORDPRESS_DB_USER=${MYSQL_USER:-wpuser}
       - WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD:-wppasswd}
     volumes:
       - ${WP_NEWSITE_DIR:-~/docker-vols/sites/newsite}:/var/www/html
     depends_on:
       - mysql_server
     expose:
       - 80
     # 關鍵：確保新站台也能自我請求
     extra_hosts:
       - "${WP_NEWSITE_VIRTUAL_HOST:-newsite.test}:host-gateway"
   ```

3. 為新網域 `newsite.test` 更新 `hosts` 檔案 (步驟 2) 和 `mkcert` 憑證 (步驟 3)。
4. 重新啟動容器：

   ```bash
   docker-compose up -d --force-recreate
   ```

## 備份與還原

### 備份資料庫

```bash
docker exec wordpress_db sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" wp_blog' > blog_backup.sql
docker exec wordpress_db sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" wp_kenming' > kenming_backup.sql
```

### 還原資料庫

```bash
cat blog_backup.sql | docker exec -i wordpress_db sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" wp_blog'
cat kenming_backup.sql | docker exec -i wordpress_db sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" wp_kenming'
```

## 常見問題

### 1. `wp_remote_post` 失敗 (Connection refused / SSL problem)

如果您已依照「HTTPS 與憑證設置」所有步驟操作但仍失敗，請執行以下驗證：

1.  **登入容器：**

   ```bash
   docker exec -it wordpress_kenming /bin/bash
   ```

2.  **(在容器內) 檢查 DNS 解析：**

   ```bash
   cat /etc/hosts
   ```

   *   **應看到：** 類似 `192.168.65.254 kenming.test` 的紀錄。
   *   _若無：_ `extra_hosts` 設定失敗或容器未重啟。

3.  **(在容器內) 檢查 SSL 信任：**

   ```bash
   ls -l /etc/ssl/certs/mkcert-rootCA.pem
   ```

   *   **應看到：** 一個指向 `/usr/local/share/ca-certificates/mkcert-rootCA.crt` 的符號連結 (symlink)。
   *   _若無：_ `Dockerfile` 建置失敗。請執行步驟 4 (同步 CA) 和步驟 6 ( `build --no-cache`)。

4.  **(在容器內) 最終測試：**

   ```bash
   curl -Iv https://kenming.test
   ```

   *   **應看到：** `SSL certificate verify ok.` 並且 `curl` 成功回傳 HTTP 標頭。
   *   _若仍失敗：_ 請檢查 `rootCA.pem` (步驟 4) 是否為 `mkcert` (步驟 3) 正在使用的**同一個**根證書。

### 2. 無法連接到網站 (瀏覽器 404 / 502)

*   確認 `nginx-proxy` 容器正在運行。
*   檢查 Windows 和 WSL 的 `hosts` 檔案 (步驟 2) 是否包含 `.test` 網域。

### 3. 資料庫連接錯誤

- 確認 MySQL 容器正在運行
- 檢查 `.env` 文件中的資料庫憑證是否正確

### 4. 權限問題

如果遇到文件權限問題，可以運行：

```bash
docker exec wordpress_blog chown -R www-data:www-data /var/www/html
docker exec wordpress_kenming chown -R www-data:www-data /var/www/html
```

### 5. 創建 nginx-proxy 網絡

如果 nginx-proxy 網絡尚未創建，請運行：

```bash
docker network create nginx-proxy
```

## 授權

此 Docker 配置遵循 MIT 授權協議。