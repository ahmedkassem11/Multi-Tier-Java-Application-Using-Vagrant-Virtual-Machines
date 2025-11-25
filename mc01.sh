#!/bin/bash
set -e

# MC01 Provisioning Script

echo "Setting up hosts file..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.56.11 web01
192.168.56.12 app01
192.168.56.13 rmq01
192.168.56.14 mc01
192.168.56.15 db01
EOF

echo "Installing Memcached..."
sudo dnf update -y
sudo dnf install memcached -y
sudo systemctl enable --now memcached

echo "Configuring Memcached to listen on all interfaces..."
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached

echo "MC01 setup complete."
