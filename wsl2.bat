wsl --install
wsl --update
wsl -v -l
wsl --list --online
wsl --install Ubuntu-22.04
wsl -d Ubuntu-22.04
wsl --shutdown

# ubuntu-22.04
df -h / # 查看磁盘大小
sudo apt update  
sudo apt upgrade
sudo apt install zsh htop nvtop
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 桌面环境
vi /etc/wsl.conf # 确认 systemd=true
sudo apt install ubuntu-desktop xwayland

sudo systemctl edit --full --force wslg-fix.service
# 粘贴
[Service]
Type=oneshot
ExecStart=-/usr/bin/umount /tmp/.X11-unix
ExecStart=/usr/bin/rm -rf /tmp/.X11-unix
ExecStart=/usr/bin/mkdir /tmp/.X11-unix
ExecStart=/usr/bin/chmod 1777 /tmp/.X11-unix
ExecStart=/usr/bin/ln -s /mnt/wslg/.X11-unix/X0 /tmp/.X11-unix/X0
ExecStart=/usr/bin/chmod 0777 /mnt/wslg/runtime-dir
ExecStart=/usr/bin/chmod 0666 /mnt/wslg/runtime-dir/wayland-0.lock

[Install]
WantedBy=multi-user.target
sudo systemctl enable wslg-fix.service

sudo systemctl edit user-runtime-dir@.service
sudo systemctl set-default multi-user.target
