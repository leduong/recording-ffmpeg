#!/bin/bash



if ! grep -qi 'ubuntu' /etc/os-release; then
	echo "This script only supports Ubuntu. Exiting."
	exit 1
fi


add_line_if_not_exists() {
	local line="$1"
	local file="$2"
	grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

add_line_if_not_exists "fs.file-max = 1048576" /etc/sysctl.conf
add_line_if_not_exists "net.core.somaxconn=65535" /etc/sysctl.conf
add_line_if_not_exists "net.ipv4.tcp_max_syn_backlog=4096" /etc/sysctl.conf
add_line_if_not_exists "o11 soft nofile 1048576" /etc/security/limits.conf
add_line_if_not_exists "o11 hard nofile 1048576" /etc/security/limits.conf
add_line_if_not_exists "DefaultLimitNOFILE=204890:524288" /etc/systemd/system.conf
sysctl -p

apt-get update && apt-get install -y ffmpeg wget
mkdir -p /home/ffmpeg
wget -O /home/ffmpeg/recording https://github.com/leduong/recording-ffmpeg/raw/refs/heads/main/recording
wget -O /home/ffmpeg/run.sh https://github.com/leduong/recording-ffmpeg/raw/refs/heads/main/run.sh
chmod +x /home/ffmpeg/recording /home/ffmpeg/run.sh


cat <<EOL > /etc/systemd/system/ffmpeg.service
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

if systemctl is-active --quiet ffmpeg.service; then
	systemctl restart ffmpeg.service
else
	systemctl enable --now ffmpeg.service
fi
