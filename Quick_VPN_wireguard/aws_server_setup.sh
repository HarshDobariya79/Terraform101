#!/bin/bash

#---------------------------------------------------------------------------------------------------------------------
# Description      : This script setup wireguard VPN in a AWS EC2 linux machine and returns config as well as qr code.
#
# Usage            : sudo ./aws_server_setup.sh
#
# Author           : https://github.com/harshdobariya79
# Create Date      : Dec 3,2023
# Last Update Date :
#---------------------------------------------------------------------------------------------------------------------



# install required packages and configure
apt-get update
apt-get update # due to terraform bug where it can't find apt packages
apt-get install -y wireguard resolvconf iptables net-tools netfilter-persistent curl qrencode
echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >/etc/sysctl.d/wg.conf
sysctl -p

# Get server IP using aws api
SERVER_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

# Generate server private key
SERVER_PRIVATE_KEY=$(wg genkey)

# Generate server public key
SERVER_PUBLIC_KEY=$(echo "$SERVER_PRIVATE_KEY" | wg pubkey)

# Generate client private key
CLIENT_PRIVATE_KEY=$(wg genkey)

# Generate client public key
CLIENT_PUBLIC_KEY=$(echo "$CLIENT_PRIVATE_KEY" | wg pubkey)

# Generate preshared key
PRESHARED_KEY=$(wg genpsk)

# Set configurations
SERVER_PUBLIC_NIC=$(ip route | awk '/default/ {print $5}')
WG_SUBNET="10.0.1.0/30"
WG_PORT="51820"
ALLOWED_IPS="0.0.0.0/0"
DNS_SERVER_1="1.1.1.1"
DNS_SERVER_2="1.0.0.1"

# Generate server config file
cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = $WG_SUBNET
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -I FORWARD -i wg0 -o wg0 -j DROP
PostUp = iptables -I INPUT -p udp --dport $WG_PORT -j ACCEPT
PostUp = iptables -I FORWARD -i $SERVER_PUBLIC_NIC -o wg0 -j ACCEPT
PostUp = iptables -I FORWARD -i wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o $SERVER_PUBLIC_NIC -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -o wg0 -j DROP
PostDown = iptables -D INPUT -p udp --dport $WG_PORT -j ACCEPT
PostDown = iptables -D FORWARD -i $SERVER_PUBLIC_NIC -o wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o $SERVER_PUBLIC_NIC -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
PresharedKey = $PRESHARED_KEY
AllowedIPs = 10.0.1.1/32
EOF

# Enable wireguard service config
systemctl enable wg-quick@wg0

# Generate client config
cat <<EOF
-----------------------------------------------------------------------
                          CLIENT CONFIG
-----------------------------------------------------------------------
EOF

echo "[Interface]
Address = 10.0.1.1/32
DNS = $DNS_SERVER_1, $DNS_SERVER_2
PrivateKey = $CLIENT_PRIVATE_KEY

[Peer]
AllowedIPs = $ALLOWED_IPS
Endpoint = $SERVER_IP:$WG_PORT
PersistentKeepalive = 25
PreSharedKey = $PRESHARED_KEY
PublicKey = $SERVER_PUBLIC_KEY"

cat <<EOF
-----------------------------------------------------------------------
EOF

qrencode -t ANSIUTF8 <<EOF
[Interface]
Address = 10.0.1.1/32
DNS = $DNS_SERVER_1, $DNS_SERVER_2
PrivateKey = $CLIENT_PRIVATE_KEY

[Peer]
AllowedIPs = $ALLOWED_IPS
Endpoint = $SERVER_IP:$WG_PORT
PersistentKeepalive = 25
PreSharedKey = $PRESHARED_KEY
PublicKey = $SERVER_PUBLIC_KEY
EOF