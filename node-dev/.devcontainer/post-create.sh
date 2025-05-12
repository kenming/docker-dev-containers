#!/bin/bash

# 增加常用 alias
echo "alias ll='ls -alF'" >> /home/node/.bashrc
echo "alias gs='git status'" >> /home/node/.bashrc
echo "alias gp='git pull'" >> /home/node/.bashrc
echo "alias gc='git commit -m'" >> /home/node/.bashrc
echo "alias pluginsdir='cd /var/www/html/wp-content/plugins'" >> /home/node/.bashrc

# 確保 .bashrc 被加載
echo "source /home/node/.bashrc" >> /home/node/.bash_profile