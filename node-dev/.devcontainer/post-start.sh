#!/bin/bash

# 設置環境變數
echo "export NODE_ENV=development" >> /home/node/.bashrc
echo "export PATH=/home/node/.local/bin:$PATH" >> /home/node/.bashrc

# 確保變數生效
source /home/node/.bashrc