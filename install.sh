#!/bin/bash

echo "fs.file-max = 1048576" >> /etc/sysctl.conf
echo "net.core.somaxconn=65535" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog=4096" >> /etc/sysctl.conf
echo "o11 soft nofile 1048576" >> /etc/security/limits.conf
echo "o11 hard nofile 1048576" >> /etc/security/limits.conf
echo "DefaultLimitNOFILE=204890:524288" >> /etc/systemd/system.conf
sysctl -p

apt-get update && apt-get install -y ffmpeg wget
mkdir -p /home/ffmpeg
wget https://github.com/leduong/recording-ffmpeg/raw/refs/heads/main/recording -O /home/ffmpeg/recording
chmod +x recording

cat <<EOL >> /etc/systemd/system/ffmpeg.service
[Unit]
Description=Auto-start recording-ffmpeg Server
After=network.target

[Service]
ExecStart=/home/ffmpeg/run.sh
WorkingDirectory=/home/ffmpeg
Restart=always
User=root
StandardOutput=append:/var/log/ffmpeg.log
StandardError=append:/var/log/ffmpeg.log

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable --now ffmpeg.service
