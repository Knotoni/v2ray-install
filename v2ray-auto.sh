#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install shadowsocks-libev && sudo apt install haveged
sudo wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.0/v2ray-plugin-linux-amd64-v1.3.0.tar.gz
sudo tar -xf v2ray-plugin-linux-amd64-v1.3.0.tar.gz
sudo mv v2ray-plugin_linux_amd64 /etc/shadowsocks-libev/v2ray-plugin
sudo setcap 'cap_net_bind_service=+eip' /etc/shadowsocks-libev/v2ray-plugin
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/ss-server
sudo touch /etc/shadowsocks-libev/v2ray.json
echo Your password:
read pass
echo Your port:
read port
echo Your method:
read method
echo Your DNS:
read dns
cd /etc/shadowsocks-libev/
cat <<EOT>> v2ray.json
{
	"server":"0.0.0.0",
	"server_port":$port,
	"password":"$pass",
	"local_port":1080,
	"timeout":300,
	"method":"$method",
	"fast_open":true,
	"reuse_port":true,
	"plugin":"/etc/shadowsocks-libev/v2ray-plugin",
	"plugin_opts":"server",
	"nameserver":"$dns"
}
EOT
touch /etc/systemd/system/ss-v2ray.service
cd /etc/systemd/system
cat <<EOT>> ss-v2ray.service
[Unit]
Description=Shadowsocks-libev with V2RAY-websocket obfuscation
Documentation=man:shadowsocks-libev(8)
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=51200
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/v2ray.json

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl enable ss-v2ray.service && sudo systemctl restart ss-v2ray.service
sudo systemctl status ss-v2ray