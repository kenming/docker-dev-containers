# Nginx Proxy Docker 環境

這個目錄包含用於部署 Nginx Proxy 的 Docker 配置，可用於反向代理多個容器化應用程式，實現虛擬主機和自動 SSL 配置。

## 功能特點

- 使用官方 nginxproxy/nginx-proxy:alpine 映像
- 自動發現並代理其他 Docker 容器
- 支援 HTTP 和 HTTPS
- 支援透過環境變數自定義配置
- 創建共享網絡供其他容器使用

## 系統需求

- Docker 和 Docker Compose
- 主機上的 80 和 443 端口可用

## 快速開始

### 環境設置

本專案使用 `.env` 文件存儲配置參數。請按照以下步驟設置：

1. 複製 `.env.example` 文件並重命名為 `.env`
   ```bash
   cp .env.example .env
   ```

2. 根據需要在 `.env` 文件中調整配置值

3. 確保 `.env` 文件不會被提交到版本控制系統中

### 啟動服務

在此目錄下運行以下命令啟動 Nginx Proxy：

```bash
docker-compose up -d
```

### 停止服務

```bash
docker-compose down
```

## 使用方法

### 連接其他容器

要讓 Nginx Proxy 自動代理其他容器，只需在其他容器的配置中添加以下環境變數：

```yaml
environment:
  - VIRTUAL_HOST=your-domain.localhost
  - VIRTUAL_PORT=8080  # 容器內部服務端口
```

並確保容器連接到 `nginx-proxy` 網絡：

```yaml
networks:
  - nginx-proxy

networks:
  nginx-proxy:
    external: true
```

### 設置靜態圖片伺服器範例 (`images.kenming.idv.tw`)

要設置一個專門用於靜態圖片的子域名，您需要創建一個新的 Nginx 服務容器並將本地圖片目錄掛載進去：

1.  **Host 檔案設定：** 確保 Host 檔案中將域名指向 `127.0.0.1`。

    ```text
    127.0.0.1    images.kenming.idv.tw
    ```

2.  **新增 Docker 服務：** 在您的 `docker-compose.yml` 中新增以下服務，並調整 `IMAGE_DIR` 為您本機的圖片路徑：

    ```yaml
    image_server:
      image: nginx:alpine
      container_name: image_kenming
      restart: always
      environment:
        - VIRTUAL_HOST=images.kenming.idv.tw
        - VIRTUAL_PORT=80
      volumes:
        - ${IMAGE_DIR:-~/docker-vols/sites/image_kenming}:/usr/share/nginx/html:ro
      expose:
        - 80
      networks:
        - nginx-proxy
    ```

### 添加 SSL 支援（自簽署憑證用於本地開發）

由於 `nginx-proxy` 使用了 Host 掛載點 (`~/docker-vols/nginx/certs`) 來管理憑證，對於本地開發環境（如 `images.kenming.idv.tw` 或 `kenming.localhost`），請遵循以下步驟：

1.  **安裝 `mkcert`：** 在您的 WSL 環境中安裝並執行 `mkcert -install`。
2.  **生成憑證：** 在 `~/docker-vols/nginx/certs` 目錄中，為您的域名生成憑證：
    ```bash
    mkcert images.kenming.idv.tw kenming.localhost
    ```
3.  **重新命名檔案：** 將 `.pem` 檔案重新命名為 `.crt` 和 `.key`：
    ```bash
    mv images.kenming.idv.tw.pem images.kenming.idv.tw.crt
    mv images.kenming.idv.tw-key.pem images.kenming.idv.tw.key
    # 針對 kenming.localhost 執行同樣操作
    ```
4.  **匯入 CA：** 將 `mkcert` 生成的根 CA 憑證（使用 `mkcert -CAROOT` 查找路徑）**匯入到您的 Windows 11 系統的「受信任的根憑證授權單位」清單中**。
5.  **重啟服務：** 執行 `docker-compose down` 後再 `docker-compose up -d` 讓 Nginx Proxy 讀取新憑證。


## 環境變數說明

| 變數名稱 | 說明 | 預設值 |
|----------|------|--------|
| NGINX\_PROXY\_CONTAINER\_NAME | 容器名稱 | nginx-proxy |
| NGINX\_PROXY\_IMAGE | 使用的映像 | nginxproxy/nginx-proxy:alpine |
| HTTP\_PORT | HTTP 端口 | 80 |
| HTTPS\_PORT | HTTPS 端口 | 443 |
| NGINX\_CONF\_DIR | Nginx 配置目錄 | \~/docker-vols/nginx/conf.d/ |
| **IMAGE\_DIR** | **圖片伺服器 (`image_server`) 的本機圖片根目錄** | **\~/docker-vols/sites/image\_kenming** |
| NETWORK\_NAME | Docker 網絡名稱 | nginx-proxy |

## 目錄結構

  - `/etc/nginx/conf.d/`: Nginx 配置文件目錄
  - `/etc/nginx/vhost.d/`: 虛擬主機配置目錄
  - `/usr/share/nginx/html/`: 默認 HTML 文件目錄
  - `/etc/nginx/certs/`: **SSL 證書目錄 (由 Host 掛載：`~/docker-vols/nginx/certs`)**

## 自定義配置

### 添加自定義 Nginx 配置

您可以在主機的 `~/docker-vols/nginx/conf.d/` 目錄中添加 `.conf` 文件，這些文件會被自動加載。

### 修改默認超時設置

創建 `~/docker-vols/nginx/conf.d/timeout.conf` 文件：

```nginx
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
send_timeout 600;
```

## 常見問題

### 端口衝突

如果出現端口衝突，可以在 `.env` 文件中修改 `HTTP_PORT` 和 `HTTPS_PORT` 變數。

### 無法連接到容器

- 確認容器已設置 `VIRTUAL_HOST` 環境變數
- 確認容器已連接到 `nginx-proxy` 網絡
- 檢查 Nginx 日誌：`docker logs nginx-proxy`

### 創建 nginx-proxy 網絡

如果 nginx-proxy 網絡尚未創建，請運行：

```bash
docker network create nginx-proxy
```

## 授權

此 Docker 配置遵循 MIT 授權協議。