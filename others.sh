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
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
sudo npm install -g @anthropic-ai/claude-code
claude --version

# claude-code-router
sudo npm install -g @musistudio/claude-code-router
mkdir -p ~/.claude-code-router && touch ~/.claude-code-router/config.json
code ~/.claude-code-router/config.json 

claude /logout

export ANTHROPIC_AUTH_TOKEN="sk-b4YbhY0MrjpNKDOkH56Gm0bJsULYtmHzlqgFXFV73gQboKHe"
export ANTHROPIC_BASE_URL="https://feiai.chat"
claude

export ANTHROPIC_AUTH_TOKEN="sk-gHlMop0fxXhZL1KD8v16QLbP6eGytZS1K9XR3ijODiXI4sJH"
export ANTHROPIC_BASE_URL="https://aizex.top"
claude

code ~/.codex/auth.json  #添加sk
vi ~/.codex/config.toml  #添加base_url
model_provider = "api111"
model = "gpt-5-codex"
model_reasoning_effort = "high"
disable_response_storage = true
preferred_auth_method = "apikey"

[model_providers.api111]
name = "api111"
base_url = "https://feiai.chat/v1"
wire_api = "responses"
