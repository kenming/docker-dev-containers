FROM node:18

# 將 node 用戶加入 www-data 群組
RUN usermod -a -G www-data node

# 安裝必要的工具
# RUN npm install -g npm

# 安裝基本工具
RUN apt-get update && \
    apt-get install -y sudo git curl wget zip unzip nano vim htop tree ncdu jq rsync && \
    # 為 node 用戶設置 sudo 權限
    usermod -aG sudo node && \
    echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node && \
    chmod 0440 /etc/sudoers.d/node