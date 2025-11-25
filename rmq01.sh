#!/bin/bash
set -e

# RMQ01 Provisioning Script

echo "Setting up hosts file..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.56.11 web01
192.168.56.12 app01
192.168.56.13 rmq01
192.168.56.14 mc01
192.168.56.15 db01
EOF

echo "Installing RabbitMQ..."
sudo dnf -y install centos-release-rabbitmq-38
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
sudo systemctl enable --now rabbitmq-server

echo "Configuring RabbitMQ..."
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

echo "Creating 'test' user..."
sudo rabbitmqctl add_user test test
sudo rabbitmqctl set_user_tags test administrator
sudo rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

echo "Configuring 'guest' user..."
sudo rabbitmqctl set_user_tags guest administrator
sudo rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"

sudo systemctl restart rabbitmq-server

echo "RMQ01 setup complete."
