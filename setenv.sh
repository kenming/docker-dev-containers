#!/bin/bash

# setenv.sh - 設置環境變數文件的符號連結
# 此腳本將 env-configs 目錄中的 .env 文件連結到各個 Docker 環境目錄

# 顯示彩色輸出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}開始設置環境變數文件...${NC}"

# 檢查 env-configs 目錄是否存在
if [ ! -d "env-configs" ]; then
  echo -e "${RED}錯誤: env-configs 目錄不存在${NC}"
  echo -e "${YELLOW}請確保已克隆 env-configs 子模組:${NC}"
  echo -e "git submodule update --init --recursive"
  exit 1
fi

# 遍歷所有子目錄
for dir in */; do
  # 排除 env-configs 目錄和隱藏目錄
  if [ "$dir" != "env-configs/" ] && [[ ! "$dir" =~ ^\..* ]]; then
    dir_name=${dir%/}
    
    # 排除當前目錄本身
    if [ "$dir_name" = "." ] || [ "$dir_name" = ".." ]; then
      continue
    fi
    
    # 檢查對應的環境配置目錄是否存在
    if [ -d "env-configs/$dir_name" ]; then
      # 檢查環境配置文件是否存在
      if [ -f "env-configs/$dir_name/.env" ]; then
        echo -e "${GREEN}設置 $dir_name 的環境變數文件...${NC}"
        
        # 如果目標目錄中已存在 .env 文件，先備份
        if [ -f "$dir_name/.env" ] && [ ! -L "$dir_name/.env" ]; then
          echo -e "${YELLOW}備份 $dir_name/.env 到 $dir_name/.env.bak${NC}"
          mv "$dir_name/.env" "$dir_name/.env.bak"
        fi
        
        # 刪除已存在的符號連結
        if [ -L "$dir_name/.env" ]; then
          rm "$dir_name/.env"
        fi
        
        # 創建符號連結
        ln -sf "../env-configs/$dir_name/.env" "$dir_name/.env"
        echo -e "${GREEN}✓ $dir_name 環境變數設置完成${NC}"
      else
        echo -e "${YELLOW}警告: env-configs/$dir_name/.env 文件不存在，跳過${NC}"
      fi
    else
      # 只在目錄名不是 "docker" 時顯示警告
      if [ "$dir_name" != "docker" ]; then
        echo -e "${YELLOW}警告: $dir_name 沒有對應的環境配置目錄，跳過${NC}"
      fi
    fi
  fi
done

echo -e "${GREEN}環境變數設置完成!${NC}"
echo -e "${YELLOW}提示: 如果您看到警告，可能需要在 env-configs 中創建相應的目錄和 .env 文件${NC}"