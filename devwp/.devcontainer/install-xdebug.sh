#!/bin/bash

# 檢查 Xdebug 是否已安裝
if php -m | grep -q xdebug; then
  echo "Xdebug 已安裝"
else
  echo "安裝 Xdebug..."
  sudo apt-get update
  sudo apt-get install -y \
    libzip-dev \
    zip
  
  sudo pecl install xdebug
  
  # 獲取 Xdebug 擴展路徑
  XDEBUG_PATH=$(find /usr/local/lib/php/extensions -name "xdebug.so")
  echo "Xdebug 路徑: $XDEBUG_PATH"

  # 檢查是否找到 xdebug.so
  if [ -z "$XDEBUG_PATH" ]; then
    echo "錯誤：找不到 xdebug.so 文件"
    exit 1
  fi

  # 配置 Xdebug
  sudo bash -c "cat > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini << EOL
zend_extension=${XDEBUG_PATH}
xdebug.mode=debug,develop
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.start_with_request=yes
xdebug.discover_client_host=0
xdebug.log=/tmp/xdebug.log
xdebug.log_level=7
xdebug.idekey=VSCODE
EOL"

  # 重啟 Apache
  if command -v apache2ctl &> /dev/null; then
    echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf > /dev/null
    sudo apache2ctl -k graceful
  fi

  # 確認 Xdebug 已啟用
  if php -v | grep -i xdebug; then
    echo "Xdebug 安裝和配置成功完成。"
  else
    echo "警告：Xdebug 似乎未正確加載，請檢查配置。"
  fi

  # 創建測試文件
  echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/xdebug-test.php > /dev/null
  echo "創建了測試文件：/var/www/html/xdebug-test.php"
  echo "請訪問 http://devwp.localhost/xdebug-test.php 檢查 Xdebug 配置"
fi