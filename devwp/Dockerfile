FROM wordpress:php8.3

# 安裝必要的工具
RUN apt-get update && \
    apt-get install -y sudo git curl wget zip unzip nano vim htop tree ncdu jq rsync && \
    apt-get clean

# 新增 vscode 使用者並設置 sudo 權限
RUN useradd -ms /bin/bash vscode && \
    usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode