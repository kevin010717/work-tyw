sudo apt update
sudo apt upgrade
sudo apt install nvtop
sudo apt install gcc git

# nvidia-550
ubuntu-drivers devices
sudo ubuntu-drivers autoinstall
sudo apt install nvidia-driver-550
# sudo apt install nvidia-driver-570
# sudo dmesg | grep -i nvidia
# sudo apt purge 'nvidia*'

# cuda=12.8
wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda_12.8.0_570.86.10_linux.run
sudo sh cuda_12.8.0_570.86.10_linux.run
echo 'export PATH=/usr/local/cuda-12.4/bin:$PATH' >> ~/.zshrc        # CUDA 12.4 命令路径
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LD_LIBRARY_PATH' >> ~/.zshrc  # CUDA 运行库路径
echo 'export LIBRARY_PATH=/usr/local/cuda-12.4/lib64:$LIBRARY_PATH' >> ~/.zshrc        # CUDA 编译库路径
nvcc --verision

# miniconda
wget --no-proxy https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh

# isaacsim450
# 重新打开一个终端
conda create -n isaacsim450 python=3.10
conda activate isaacsim450
pip install "isaacsim[all]==4.5.0" --extra-index-url https://pypi.nvidia.com
pip install "isaacsim[extscache]==4.5.0" --extra-index-url https://pypi.nvidia.com

# isaacsim500
# 重新打开一个终端
conda create -n isaacsim500 python=3.11
conda activate isaacsim500
pip install --upgrade pip
pip install pyyaml typeguard
pip install torch==2.7.0 torchvision==0.22.0 --index-url https://download.pytorch.org/whl/cu128
pip install "isaacsim[all,extscache]==5.0.0" --extra-index-url https://pypi.nvidia.com

# isaaclab
git clone https://github.com/isaac-sim/IsaacLab.git
sudo apt install cmake build-essential
cd IsaacLab
./isaaclab.sh --install # or "./isaaclab.sh -i"
./isaaclab.sh --help
./isaaclab.sh -p scripts/tutorials/00_sim/create_empty.py
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Ant-v0 --headless
./isaaclab.sh -p scripts/reinforcement_learning/rsl_rl/train.py --task=Isaac-Velocity-Rough-Anymal-C-v0 --headless

# ros2 hummble
source <(wget -qO- http://fishros.com/install)
source /opt/ros/humble/setup.zsh 

# ros2 bridge
sudo apt-get install -y 
ros-humble-ros-testing 
ros-humble-moveit 
ros-humble-moveit-common 
ros-humble-control-toolbox 
ros-humble-ros2-control 
ros-humble-ros2-controllers
ros-humble-ros-base 
ros-humble-rmw-fastrtps-cpp 
ros-humble-rmw-cyclonedds-cpp
echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp"
echo "export LD_LIBRARY_PATH=/opt/ros/humble/lib:\$LD_LIBRARY_PATH"
echo "export ROS_DOMAIN_ID=0"
pip install catkin_pkg pandas pyarrow

# lerobot
# 创建lerobot虚拟环境
conda create -y -n lerobot python=3.11
conda activate lerobot
conda install ffmpeg -c conda-forge
pip install opencv-python
# lerobot安装
git clone https://github.com/huggingface/lerobot.git
cd lerobot
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip install -e . 
pip install -e ".[aloha, pusht]"
pip install lerobot
# 数据集可视化1
python -m lerobot.scripts.visualize_dataset \
    --repo-id lerobot/pusht \
    --episode-index 0
# 数据集可视化2
python -m lerobot.scripts.visualize_dataset     --repo-id lerobot/aloha_static_coffee     --episode-index 3
# 策略评估
lerobot-eval \
    --policy.path=lerobot/diffusion_pusht \
    --env.type=pusht \
    --eval.batch_size=10 \
    --eval.n_episodes=10 \
    --policy.use_amp=false \
    --policy.device=cuda
# 策略训练
lerobot-train --config_path=lerobot/diffusion_pusht

# leisaac
# 虚拟环境
conda create -n leisaac python=3.10
conda activate leisaac
conda install -n base -c conda-forge mamba
mamba install -c "nvidia/label/cuda-11.8.0" cuda-toolkit
# conda install -c "nvidia/label/cuda-11.8.0" cuda-toolkit
pip install torch==2.5.1 torchvision==0.20.1 --index-url https://download.pytorch.org/whl/cu118
pip install pyyaml typeguard -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install --upgrade pip
# isaacsim450
pip install 'isaacsim[all,extscache]==4.5.0' --extra-index-url https://pypi.nvidia.com
# isaaclab
git clone https://github.com/isaac-sim/IsaacLab.git
sudo apt install cmake build-essential
cd IsaacLab
git checkout v2.1.1
./isaaclab.sh --install
# leisaac
git clone https://github.com/LightwheelAI/leisaac.git
cd leisaac
pip install -e source/leisaac
# command
python leisaac/scripts/environments/teleoperation/teleop_se3_agent.py \
    --task=LeIsaac-SO101-PickOrange-v0 \
    --teleop_device=keyboard \
    --port=/dev/ttyACM0 \
    --num_envs=1 \
    --device=cuda \
    --enable_cameras \
    --record \
    --dataset_file=./datasets/dataset.hdf5


# libero
conda create -n libero python=3.8.13
conda activate libero
git clone https://github.com/Lifelong-Robot-Learning/LIBERO.git
cd LIBERO
pip install -r requirements.txt
pip install torch==1.11.0+cu113 torchvision==0.12.0+cu113 torchaudio==0.11.0 --extra-index-url https://download.pytorch.org/whl/cu113
pip install -e .
python benchmark_scripts/download_libero_datasets.py

# openpi-uv下openpi安装
conda create -n uv_envs python=3.10
conda activate uv_envs
pip install uv
git clone --recurse-submodules https://github.com/Physical-Intelligence/openpi.git
cd ~/openpi 
GIT_LFS_SKIP_SMUDGE=1 uv sync
source ./.venv/bin/activate # 激活uv的 Python 环境
# XLA_PYTHON_CLIENT_PREALLOCATE=false \
# uv run scripts/serve_policy.py --env LIBERO
uv run scripts/serve_policy.py --env LIBERO # 启动服务端监听
  
# 重开一个终端，venv-uv下安装libero 
cd ~/openpi
conda activate uv_envs
uv venv --python 3.8 examples/libero/.venv
source examples/libero/.venv/bin/activate
uv pip sync examples/libero/requirements.txt third_party/libero/requirements.txt --extra-index-url https://download.pytorch.org/whl/cu113 --index-strategy=unsafe-best-match
uv pip install -e packages/openpi-client
uv pip install -e third_party/libero
export PYTHONPATH=$PYTHONPATH:$PWD/third_party/libero
python -m libero
python examples/libero/main.py

# lerobot-kinematics
conda create -n joycon-leisaac python=3.10
conda activate joycon-leisaac
git clone https://github.com/box2ai-robotics/lerobot-kinematics.git
cd lerobot-kinematics
pip install -e .
pip install jinja2 typeguard docutils

# joycon-robotics
git clone https://github.com/box2ai-robotics/joycon-robotics.git
cd joycon-robotics
pip install -e .
sudo apt-get update
sudo apt-get install -y dkms libevdev-dev libudev-dev cmake
make install

# leisaac
# isaacsim
conda install -c "nvidia/label/cuda-11.8.0" cuda-toolkit
pip install torch==2.5.1 torchvision==0.20.1 --index-url https://download.pytorch.org/whl/cu118
pip install --upgrade pip
pip install 'isaacsim[all,extscache]==4.5.0' --extra-index-url https://pypi.nvidia.com
# isaaclab
git clone https://github.com/isaac-sim/IsaacLab.git
sudo apt install cmake build-essential
cd IsaacLab
git checkout v2.1.1
./isaaclab.sh --install
# ERROR: pip's dependency resolver does not currently take into account all the packages that are installed. This behaviour is the source of the following dependency conflicts.
# lerobot-kinematics 0.0.1 requires numpy==1.24.4, but you have numpy 1.26.4 which is incompatible.
# leisaac
git clone https://github.com/LightwheelAI/leisaac.git
cd leisaac
pip install -e source/leisaac
python leisaac/scripts/environments/teleoperation/teleop_se3_agent.py \
    --task=LeIsaac-SO101-PickOrange-v0 \
    --teleop_device=keyboard \
    --port=/dev/ttyACM0 \
    --num_envs=1 \
    --device=cuda \
    --enable_cameras \
    --record \
    --dataset_file=./datasets/dataset.hdf5

# lerobot-mujoco-tutorial
conda install jupyter ipykernel
gh repo clone jeongeun980906/lerobot-mujoco-tutorial
cd lerobot-mujoco-tutorial
pip install -r requirements.txt
cd asset/objaverse
unzip plate_11.zip

