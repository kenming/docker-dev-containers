# WordPress Docker 環境

這個目錄包含用於快速部署多個 WordPress 網站的 Docker 配置，包括 MySQL 資料庫和 phpMyAdmin 管理界面。

## 功能特點

- 使用 WordPress PHP 8.3 官方映像
- 使用 MySQL 5.7.44 作為資料庫
- 包含 phpMyAdmin 5.2.1 管理界面
- 支援多個 WordPress 站點（blog 和 kenming）
- 使用 nginx-proxy 實現虛擬主機功能
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

要在本機環境下使用 HTTPS (例如 `https://images.kenming.idv.tw`)，您需要為 `nginx-proxy` 配置自簽署憑證並在作業系統中信任它。

1.  **安裝與設置 `mkcert`：** 在您的 WSL 環境中安裝 `mkcert` (參見外部安裝指南)，並運行：
    ```bash
    mkcert -install
    ```
2.  **Host 檔案設定：** 檢查 Windows Host 檔案 (`C:\Windows\System32\drivers\etc\hosts`) 是否包含以下映射：
    ```text
    127.0.0.1 blog.localhost kenming.localhost phpmyadmin.localhost images.kenming.idv.tw
    ```
3.  **生成憑證：** 在 Nginx Proxy 的憑證目錄（您在 Host 上的實際掛載路徑，例如 `~/docker-vols/nginx/certs`）中，為所有需要 HTTPS 的域名生成憑證：
    ```bash
    cd ~/docker-vols/nginx/certs
    mkcert kenming.localhost images.kenming.idv.tw

    # 重新命名檔案以供 Nginx Proxy 識別
    mv kenming.localhost.pem kenming.localhost.crt
    mv kenming.localhost-key.pem kenming.localhost.key
    mv images.kenming.idv.tw.pem images.kenming.idv.tw.crt
    mv images.kenming.idv.tw-key.pem images.kenming.idv.tw.key
    ```
4.  **匯入 CA 憑證至 Windows：** 將 `mkcert -CAROOT` 找到的 `rootCA.pem` 檔案匯入 Windows 系統的\*\*「受信任的根憑證授權單位」\*\*清單中。
5.  **重啟服務：** 執行 `docker-compose down` 後再 `docker-compose up -d` 讓 Nginx Proxy 讀取新憑證。

-----


## 訪問網站和管理工具

### WordPress 網站

- Blog 網站：http://blog.localhost
- Kenming 網站：http://kenming.localhost

### phpMyAdmin

- 管理界面：http://phpmyadmin.localhost
- 使用者：root
- 密碼：(您在 .env 文件中設置的 MYSQL_ROOT_PASSWORD)

## 環境變數說明

### MySQL 設定
| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| MYSQL_CONTAINER_NAME | MySQL 容器名稱 | wordpress_db |
| MYSQL_VERSION | MySQL 版本 | 5.7.44 |
| MYSQL_DATABASE | 默認資料庫名稱 | wp_blog |
| MYSQL_USER | MySQL 使用者名稱 | wpuser |
| MYSQL_PASSWORD | MySQL 使用者密碼 | wppasswd |
| MYSQL_ROOT_PASSWORD | MySQL root 密碼 | dbpasswd |
| MYSQL_DATA_DIR | MySQL 資料目錄 | ~/docker-vols/db_data/mysql |

### phpMyAdmin 設定
| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| PMA_CONTAINER_NAME | phpMyAdmin 容器名稱 | phpmyadmin |
| PMA_VERSION | phpMyAdmin 版本 | 5.2.1 |
| PMA_VIRTUAL_HOST | phpMyAdmin 虛擬主機名稱 | phpmyadmin.localhost |
| PMA_UPLOAD_LIMIT | 上傳檔案大小限制 | 500M |

### WordPress Blog 設定
| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| WP_BLOG_CONTAINER_NAME | Blog 容器名稱 | wordpress_blog |
| WP_BLOG_VERSION | WordPress 版本 | php8.3 |
| WP_BLOG_VIRTUAL_HOST | Blog 虛擬主機名稱 | blog.localhost |
| WP_BLOG_DB_NAME | Blog 資料庫名稱 | wp_blog |
| WP_BLOG_DIR | Blog 檔案目錄 | ~/docker-vols/sites/blog |
| WP_BLOG_DEBUG | 是否啟用除錯模式 | 未設置 |

### WordPress Kenming 設定
| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| WP_KENMING_CONTAINER_NAME | Kenming 容器名稱 | wordpress_kenming |
| WP_KENMING_VERSION | WordPress 版本 | php8.3 |
| WP_KENMING_VIRTUAL_HOST | Kenming 虛擬主機名稱 | kenming.localhost |
| WP_KENMING_DB_NAME | Kenming 資料庫名稱 | wp_kenming |
| WP_KENMING_DIR | Kenming 檔案目錄 | ~/docker-vols/sites/kenming |
| WP_KENMING_DEBUG | 是否啟用除錯模式 | 未設置 |

### 圖片伺服器設定 (新增)

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| **IMAGE\_SERVER\_CONTAINER\_NAME** | 圖片伺服器容器名稱 | image\_kenming |
| **IMAGE\_DIR** | **圖片伺服器的本機檔案目錄** | **\~/docker-vols/sites/image\_kenming** |

-----

## 目錄結構 (更新)

  - `~/docker-vols/sites/blog/`: Blog WordPress 網站檔案
  - `~/docker-vols/sites/kenming/`: Kenming WordPress 網站檔案
  - **`~/docker-vols/sites/image_kenming/`:** **靜態圖片伺服器檔案**
  - `~/docker-vols/db_data/mysql/`: MySQL 資料庫檔案

-----

## 添加新的 WordPress 網站

若要添加新的 WordPress 網站，請按照以下步驟：

1. 在 `.env` 文件中添加新站點的配置：
   ```
   WP_NEWSITE_CONTAINER_NAME=wordpress_newsite
   WP_NEWSITE_VERSION=php8.3
   WP_NEWSITE_VIRTUAL_HOST=newsite.localhost
   WP_NEWSITE_DB_NAME=wp_newsite
   WP_NEWSITE_DIR=~/docker-vols/sites/newsite
   ```

2. 在 `docker-compose.yml` 文件中添加新的服務配置：
   ```yaml
   wordprss_newsite:
     image: wordpress:${WP_NEWSITE_VERSION:-php8.3}
     container_name: ${WP_NEWSITE_CONTAINER_NAME:-wordpress_newsite}
     restart: always
     environment:
         - VIRTUAL_HOST=${WP_NEWSITE_VIRTUAL_HOST:-newsite.localhost}
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
   ```

3. 重新啟動容器：
   ```bash
   docker-compose up -d
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

### 無法連接到網站

- 確認 nginx-proxy 容器正在運行
- 檢查 `/etc/hosts` 文件是否包含必要的本地域名映射：
  ```
  127.0.0.1 blog.localhost kenming.localhost phpmyadmin.localhost
  ```

### 資料庫連接錯誤

- 確認 MySQL 容器正在運行
- 檢查 `.env` 文件中的資料庫憑證是否正確

### 權限問題

如果遇到文件權限問題，可以運行：

```bash
docker exec wordpress_blog chown -R www-data:www-data /var/www/html
docker exec wordpress_kenming chown -R www-data:www-data /var/www/html
```

### 創建 nginx-proxy 網絡

如果 nginx-proxy 網絡尚未創建，請運行：

```bash
docker network create nginx-proxy
```

## 授權

此 Docker 配置遵循 MIT 授權協議。