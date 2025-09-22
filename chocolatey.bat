Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco --version
choco install chocolatey-core.extension
choco list 
choco upgrade all -y
choco search wechat
choco install chocolateygui -y
choco install vlc -y
choco unintall vlc -y
