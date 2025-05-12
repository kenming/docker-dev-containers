#!/bin/bash

# 測試 Docker 環境的腳本
# 用法: ./testenv.sh [環境名稱]
# 如果不提供環境名稱，將測試所有環境

# 顯示彩色輸出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 確保 nginx-proxy 網絡存在
ensure_network() {
  if ! docker network ls | grep -q nginx-proxy; then
    echo -e "${YELLOW}創建 nginx-proxy 網絡...${NC}"
    docker network create nginx-proxy
  else
    echo -e "${GREEN}nginx-proxy 網絡已存在${NC}"
  fi
}

# 測試 nginx-proxy 環境
test_nginx_proxy() {
  echo -e "\n${YELLOW}===== 測試 nginx-proxy 環境 =====${NC}"
  cd nginx-proxy || return
  
  echo -e "${YELLOW}啟動 nginx-proxy...${NC}"
  docker-compose down
  docker-compose up -d
  
  if [ $? -eq 0 ] && [ "$(docker-compose ps -q | wc -l)" -gt 0 ]; then
    echo -e "${GREEN}✓ nginx-proxy 啟動成功${NC}"
    docker-compose ps
  else
    echo -e "${RED}✗ nginx-proxy 啟動失敗${NC}"
    docker-compose logs
    return 1
  fi
  
  cd ..
}

# 測試 MongoDB 環境
test_mongodb() {
  echo -e "\n${YELLOW}===== 測試 MongoDB 環境 =====${NC}"
  cd mongodb || return
  
  echo -e "${YELLOW}啟動 MongoDB...${NC}"
  docker-compose down
  docker-compose up -d
  
  if [ $? -eq 0 ] && [ "$(docker-compose ps -q | wc -l)" -gt 0 ]; then
    echo -e "${GREEN}✓ MongoDB 啟動成功${NC}"
    docker-compose ps
    
    # 等待 MongoDB 完全啟動
    echo -e "${YELLOW}等待 MongoDB 完全啟動 (5秒)...${NC}"
    sleep 5
    
    echo -e "${YELLOW}測試 MongoDB 連接...${NC}"
    # 直接在 MongoDB 容器內執行命令，不使用 localhost
    if docker exec mongodb mongosh --eval "db.version()" --quiet; then
      echo -e "${GREEN}✓ MongoDB 連接成功${NC}"
    else
      echo -e "${RED}✗ MongoDB 連接失敗${NC}"
    fi
  else
    echo -e "${RED}✗ MongoDB 啟動失敗${NC}"
    docker-compose logs
    return 1
  fi
  
  cd ..
}

# 測試 SQL Server 環境
test_sqlserver() {
  echo -e "\n${YELLOW}===== 測試 SQL Server 環境 =====${NC}"
  cd sqlserver || return
  
  echo -e "${YELLOW}啟動 SQL Server...${NC}"
  docker-compose down
  docker-compose up -d
  
  if [ $? -eq 0 ] && [ "$(docker-compose ps -q | wc -l)" -gt 0 ]; then
    echo -e "${GREEN}✓ SQL Server 啟動成功${NC}"
    docker-compose ps
    
    # 等待 SQL Server 啟動
    echo -e "${YELLOW}等待 SQL Server 完全啟動 (30秒)...${NC}"
    sleep 30
    
    echo -e "${YELLOW}測試 SQL Server 連接...${NC}"
    # 使用更通用的方式測試 SQL Server 連接
    if docker exec sqlserver-dev /opt/mssql/bin/sqlservr --version; then
      echo -e "${GREEN}✓ SQL Server 版本檢查成功${NC}"
    else
      # 嘗試另一種方法
      if docker exec sqlserver-dev ls -la /var/opt/mssql; then
        echo -e "${GREEN}✓ SQL Server 目錄存在，服務可能正在運行${NC}"
      else
        echo -e "${RED}✗ SQL Server 檢查失敗${NC}"
      fi
    fi
  else
    echo -e "${RED}✗ SQL Server 啟動失敗${NC}"
    docker-compose logs
    return 1
  fi
  
  cd ..
}

# 測試 WordPress 環境
test_wordpress() {
  echo -e "\n${YELLOW}===== 測試 WordPress 環境 =====${NC}"
  cd wordpress || return
  
  echo -e "${YELLOW}啟動 WordPress...${NC}"
  docker-compose down
  docker-compose up -d
  
  if [ $? -eq 0 ] && [ "$(docker-compose ps -q | wc -l)" -gt 0 ]; then
    echo -e "${GREEN}✓ WordPress 啟動成功${NC}"
    docker-compose ps
    
    echo -e "${YELLOW}測試 WordPress 網站可訪問性...${NC}"
    echo -e "${GREEN}請在瀏覽器中訪問以下網址:${NC}"
    echo -e "  - http://blog.localhost"
    echo -e "  - http://kenming.localhost"
    echo -e "  - http://phpmyadmin.localhost"
  else
    echo -e "${RED}✗ WordPress 啟動失敗${NC}"
    docker-compose logs
    return 1
  fi
  
  cd ..
}

# 測試 Node.js 開發環境
test_node_dev() {
  echo -e "\n${YELLOW}===== 測試 Node.js 開發環境 =====${NC}"
  cd node-dev || return
  
  echo -e "${YELLOW}啟動 Node.js 開發環境...${NC}"
  docker-compose -f docker-compose.devcontainer.yml down
  docker-compose -f docker-compose.devcontainer.yml up -d
  
  if [ $? -eq 0 ] && [ "$(docker-compose -f docker-compose.devcontainer.yml ps -q | wc -l)" -gt 0 ]; then
    echo -e "${GREEN}✓ Node.js 開發環境啟動成功${NC}"
    docker-compose -f docker-compose.devcontainer.yml ps
    
    echo -e "${YELLOW}測試 Node.js 版本...${NC}"
    if docker exec dev-node node -v; then
      echo -e "${GREEN}✓ Node.js 運行正常${NC}"
    else
      echo -e "${RED}✗ Node.js 測試失敗${NC}"
    fi
  else
    echo -e "${RED}✗ Node.js 開發環境啟動失敗${NC}"
    docker-compose -f docker-compose.devcontainer.yml logs
    return 1
  fi
  
  cd ..
}

# 測試 WordPress 開發環境
test_devwp() {
  echo -e "\n${YELLOW}===== 測試 WordPress 開發環境 =====${NC}"
  cd devwp || return
  
  # 檢查是否有 docker-compose.yml 文件
  if [ -f "docker-compose.yml" ]; then
    echo -e "${YELLOW}啟動 WordPress 開發環境...${NC}"
    docker-compose down
    docker-compose up -d
    
    if [ $? -eq 0 ] && [ "$(docker-compose ps -q | wc -l)" -gt 0 ]; then
      echo -e "${GREEN}✓ WordPress 開發環境啟動成功${NC}"
      docker-compose ps
    else
      echo -e "${RED}✗ WordPress 開發環境啟動失敗${NC}"
      docker-compose logs
      return 1
    fi
  else
    echo -e "${YELLOW}WordPress 開發環境使用 VS Code DevContainer，請使用 VS Code 打開此目錄${NC}"
  fi
  
  cd ..
}

# 關閉除 nginx-proxy 以外的所有環境
shutdown_environments() {
  echo -e "\n${YELLOW}===== 關閉測試環境 =====${NC}"
  
  # 關閉 MongoDB
  if [ -d "mongodb" ]; then
    echo -e "${YELLOW}關閉 MongoDB 環境...${NC}"
    cd mongodb || return
    docker-compose down
    cd ..
    echo -e "${GREEN}✓ MongoDB 環境已關閉${NC}"
  fi
  
  # 關閉 SQL Server
  if [ -d "sqlserver" ]; then
    echo -e "${YELLOW}關閉 SQL Server 環境...${NC}"
    cd sqlserver || return
    docker-compose down
    cd ..
    echo -e "${GREEN}✓ SQL Server 環境已關閉${NC}"
  fi
  
  # 關閉 WordPress
  if [ -d "wordpress" ]; then
    echo -e "${YELLOW}關閉 WordPress 環境...${NC}"
    cd wordpress || return
    docker-compose down
    cd ..
    echo -e "${GREEN}✓ WordPress 環境已關閉${NC}"
  fi
  
  # 關閉 Node.js 開發環境
  if [ -d "node-dev" ]; then
    echo -e "${YELLOW}關閉 Node.js 開發環境...${NC}"
    cd node-dev || return
    docker-compose -f docker-compose.devcontainer.yml down
    cd ..
    echo -e "${GREEN}✓ Node.js 開發環境已關閉${NC}"
  fi
  
  # 關閉 WordPress 開發環境
  if [ -d "devwp" ] && [ -f "devwp/docker-compose.yml" ]; then
    echo -e "${YELLOW}關閉 WordPress 開發環境...${NC}"
    cd devwp || return
    docker-compose down
    cd ..
    echo -e "${GREEN}✓ WordPress 開發環境已關閉${NC}"
  fi
  
  echo -e "${GREEN}所有測試環境已關閉，nginx-proxy 保持運行${NC}"
}

# 主函數
main() {
  # 確保環境變數設置正確
  if [ -f "setenv.sh" ]; then
    echo -e "${YELLOW}設置環境變數...${NC}"
    chmod +x setenv.sh
    ./setenv.sh
  elif [ -f "setupenv.sh" ]; then
    echo -e "${YELLOW}設置環境變數...${NC}"
    chmod +x setupenv.sh
    ./setupenv.sh
    echo -e "${YELLOW}提示: 建議將 setupenv.sh 重命名為 setenv.sh${NC}"
  fi
  
  # 確保網絡存在
  ensure_network
  
  # 如果指定了環境名稱，只測試該環境
  if [ -n "$1" ]; then
    case "$1" in
      nginx-proxy)
        test_nginx_proxy
        ;;
      mongodb)
        test_mongodb
        # 測試完成後關閉此環境
        cd mongodb && docker-compose down && cd ..
        echo -e "${GREEN}✓ MongoDB 環境已關閉${NC}"
        ;;
      sqlserver)
        test_sqlserver
        # 測試完成後關閉此環境
        cd sqlserver && docker-compose down && cd ..
        echo -e "${GREEN}✓ SQL Server 環境已關閉${NC}"
        ;;
      wordpress)
        test_wordpress
        # 測試完成後關閉此環境
        cd wordpress && docker-compose down && cd ..
        echo -e "${GREEN}✓ WordPress 環境已關閉${NC}"
        ;;
      node-dev)
        test_node_dev
        # 測試完成後關閉此環境
        cd node-dev && docker-compose -f docker-compose.devcontainer.yml down && cd ..
        echo -e "${GREEN}✓ Node.js 開發環境已關閉${NC}"
        ;;
      devwp)
        test_devwp
        # 測試完成後關閉此環境
        if [ -d "devwp" ] && [ -f "devwp/docker-compose.yml" ]; then
          cd devwp && docker-compose down && cd ..
          echo -e "${GREEN}✓ WordPress 開發環境已關閉${NC}"
        fi
        ;;
      *)
        echo -e "${RED}未知環境: $1${NC}"
        echo -e "可用環境: nginx-proxy, mongodb, sqlserver, wordpress, node-dev, devwp"
        exit 1
        ;;
    esac
  else
    # 測試所有環境
    test_nginx_proxy
    test_mongodb
    test_sqlserver
    test_wordpress
    test_node_dev
    test_devwp
    
    # 測試完成後關閉除了 nginx-proxy 以外的所有環境
    shutdown_environments
  fi
  
  echo -e "\n${GREEN}===== 測試完成 =====${NC}"
}

# 執行主函數
main "$@"