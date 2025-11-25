# Multi-Tier-Java-Application-Using-Vagrant-Virtual-Machines
This project sets up a multi-machine local development environment using Vagrant and VirtualBox. It provisions five virtual machines with specific roles and configurations.

Prerequisites
Before you begin, ensure you have the following installed:

VirtualBox
Vagrant
Recommended Plugins
It is highly recommended to install the vagrant-hostmanager plugin to automatically manage your /etc/hosts file for easier VM-to-VM communication.

vagrant plugin install vagrant-hostmanager
Virtual Machines
The environment consists of the following VMs, all running CentOS Stream 9 (eurolinux-vagrant/centos-stream-9):

Hostname	IP Address	Memory	Role/Script
web01	192.168.56.11	1024MB	Web Server (web01.sh)
app01	192.168.56.12	4096MB	Application Server (app01.sh)
rmq01	192.168.56.13	1024MB	RabbitMQ Server (rmq01.sh)
mc01	192.168.56.14	1024MB	Memcached Server (mc01.sh)
db01	192.168.56.15	2048MB	Database Server (db01.sh)
Usage
Starting the Environment
To bring up all virtual machines:

vagrant up
To bring up a specific machine (e.g., web01):

vagrant up web01
Accessing VMs
To SSH into a specific machine:

vagrant ssh <hostname>
# Example:
vagrant ssh web01
Stopping the Environment
To stop all machines:

vagrant halt
To destroy the environment (delete all VMs):

vagrant destroy
Provisioning
Each VM is provisioned using a specific shell script located in the project root. You can re-run the provisioning scripts without destroying the VMs by running:

vagrant provision
# OR for a specific machine
vagrant provision web01
