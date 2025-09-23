# autodl使用tmux
sudo apt install nvtop tmux -y
tmux new -s train
ctl+b d
tmux attach -t train

# ubuntu 设置swap
sudo swapoff /swapfile
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
swapon --show
free -h

# 百度网盘
pip install bypy
bypy info

# google driver
pip install gdown

# claude cli
sudo apt remove nodejs -y
sudo apt remove --purge libnode-dev
sudo apt autoremove
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
sudo npm install -g @anthropic-ai/claude-code
claude --version
npm install -g @musistudio/claude-code-router
