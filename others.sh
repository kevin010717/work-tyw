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

# 