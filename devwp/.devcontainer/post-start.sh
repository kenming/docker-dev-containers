#!/bin/bash

# 設置顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 啟動 WordPress 開發環境 ===${NC}"

# 檢查並啟動必要的服務
echo -e "${GREEN}檢查並啟動必要的服務...${NC}"
if command -v apache2ctl &> /dev/null; then
  echo -e "${YELLOW}重啟 Apache 服務...${NC}"
  sudo apache2ctl -k graceful
else
  echo -e "${YELLOW}警告: 未找到 Apache，請檢查服務是否正確安裝。${NC}"
fi

# 檢查 WordPress 配置
if [ -f /var/www/html/wp-config.php ]; then
  echo -e "${GREEN}WordPress 配置檔案已存在。${NC}"
else
  echo -e "${YELLOW}警告: 未找到 wp-config.php，請檢查 WordPress 是否已正確安裝。${NC}"
fi

# 顯示環境資訊
echo -e "${GREEN}環境資訊:${NC}"
echo -e "${YELLOW}PHP 版本:${NC} $(php -v | head -n 1)"
if command -v wp &> /dev/null; then
  echo -e "${YELLOW}WP-CLI 版本:${NC} $(wp --version)"
else
  echo -e "${YELLOW}WP-CLI 未安裝。請執行以下命令手動安裝：${NC}"
  echo -e "  curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
  echo -e "  chmod +x /tmp/wp-cli.phar"
  echo -e "  sudo mv /tmp/wp-cli.phar /usr/local/bin/wp"
fi

# 提供開發提示
echo -e "${GREEN}開發環境已準備就緒！${NC}"
echo -e "${YELLOW}提示:${NC}"
echo -e "  - 使用 wp-cli 管理 WordPress 站台"
echo -e "  - 進入 /var/www/html 開始開發站台"
echo -e "  - 進入 /home/projects/wp-plugins 開始開發插件"