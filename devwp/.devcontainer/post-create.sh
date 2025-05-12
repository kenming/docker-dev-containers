#!/bin/bash

# 安裝 WP-CLI
if ! command -v wp &> /dev/null; then
  echo "安裝 WP-CLI..."
  curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  if [ $? -ne 0 ]; then
    echo "錯誤：無法下載 WP-CLI。請檢查網路連線。"
    exit 1
  fi
  chmod +x /tmp/wp-cli.phar
  sudo mv /tmp/wp-cli.phar /usr/local/bin/wp
  if [ $? -eq 0 ]; then
    echo "WP-CLI 安裝完成。"
  else
    echo "錯誤：無法將 WP-CLI 移動到 /usr/local/bin。請檢查權限。"
    exit 1
  fi
else
  echo "WP-CLI 已安裝。"
fi

# 建立 WP-CLI 配置
mkdir -p ~/.wp-cli
cat > ~/.wp-cli/config.yml << EOL
path: /var/www/html
EOL

# 設置 bash 別名以方便使用
cat > /etc/profile.d/aliases.sh << EOL
# WordPress 開發相關別名
alias wpdir="cd /var/www/html"
alias devdir="cd /home/devwp"
EOL

chmod +x /etc/profile.d/aliases.sh

echo "開發環境初始化完成!"
echo "您可以使用以下別名快速導航:"
echo "  - wpdir: 進入 WordPress 安裝目錄"
echo "  - devdir: 進入開發目錄"
echo "  - plugindir: 進入插件開發目錄"
echo "  - themedir: 進入主題開發目錄"
echo "權限管理命令:"
echo "  - fixperms: 修復 WordPress 內容目錄權限"
echo "  - fixdev: 修復開發目錄權限"