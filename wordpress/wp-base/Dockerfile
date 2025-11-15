ARG WP_VERSION=php8.3
FROM wordpress:${WP_VERSION}

# 1. 先將 mkcert 根證書複製到正確的系統路徑
COPY mkcert-rootCA.pem /usr/local/share/ca-certificates/mkcert-rootCA.crt

# 2. 安裝 ca-certificates 套件並執行更新
#    update-ca-certificates 會自動找到上一步複製進去的 .crt 檔案並將其加入信任
RUN apt-get update && apt-get install -y ca-certificates \
    && update-ca-certificates