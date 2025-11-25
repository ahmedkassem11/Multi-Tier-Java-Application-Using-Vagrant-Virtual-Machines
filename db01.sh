#!/bin/bash
set -e

# DB01 Provisioning Script

echo "Setting up hosts file..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.56.11 web01
192.168.56.12 app01
192.168.56.13 rmq01
192.168.56.14 mc01
192.168.56.15 db01
EOF

echo "Updating system and installing dependencies..."
sudo yum update -y
sudo dnf install epel-release -y
sudo dnf install git mariadb-server expect -y

echo "Starting MariaDB..."
sudo systemctl enable --now mariadb

# Define the security credentials
NEW_PASSWORD="admin123" 

# echo "Starting non-interactive MariaDB/MySQL security setup..."

# /usr/bin/expect <<- EOF_EXPECT
    
#     # 1. Set variables
#     set timeout 10
#     set password "${NEW_PASSWORD}"

#     # 2. Spawn the security script
#     spawn mysql_secure_installation

#     # 3. Enter current password (Enter for none)
#     expect "Enter current password for root (enter for none):"
#     send "\r" 

#     # 4. Enable unix_socket authentication? (CRITICAL STEP)
#     # Answer 'n' to ensure we can log in with a password later via the network/terminal.
#     expect "Enable unix_socket authentication?*"
#     send "n\r" 

#     # 5. Change the root password?
#     expect "Change the root password?*"
#     send "y\r"

#     # Enter New password
#     expect "New password:"
#     send "\$password\r"

#     # Re-enter New password
#     expect "Re-enter new password:"
#     send "\$password\r"

#     # 6. Remove anonymous users?
#     expect "Remove anonymous users?*"
#     send "y\r"

#     # 7. Disallow root login remotely?
#     expect "Disallow root login remotely?*"
#     send "y\r"

#     # 8. Remove test database?
#     expect "Remove test database and access to it?*"
#     send "y\r"

#     # 9. Reload privilege tables now?
#     expect "Reload privilege tables now?*"
#     send "y\r"

#     # Wait for the script to finish
#     expect eof
# EOF_EXPECT
echo "MariaDB/MySQL security hardening complete."
echo "Root password set to: ${NEW_PASSWORD}"

# --- Configuration ---
DB_PASSWORD="admin123"
DB_USER="admin"
DB_NAME="accounts"

echo "Starting database and user setup for: ${DB_NAME}"

# Use 'sudo mysql' with the required root credentials and pipe the SQL commands 
# using a Here-Document (<<EOF_SQL)
sudo mysql  <<EOF_SQL
-- 1. Create the new database
DROP DATABASE IF EXISTS accounts;
CREATE DATABASE accounts;

-- 2. Grant privileges for remote access (%) and create the user
-- Note: 'IDENTIFIED BY' creates the user if it doesn't exist
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

-- 3. Grant privileges for local access (localhost)
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';

-- 4. Apply all changes
FLUSH PRIVILEGES;

-- Note: The 'EXIT' command is not needed here as the connection closes automatically 
-- when the Here-Document ends.
EOF_SQL

if [ $? -eq 0 ]; then
    echo "Database '${DB_NAME}' and user '${DB_USER}' configured successfully."
else
    echo "ERROR: Database/user setup failed. Double-check the root password and privileges."
    exit 1
fi

echo "Cloning source code and restoring database..."
cd /tmp
if [ -d sourcecodeseniorwr ]; then
    echo "Directory 'sourcecodeseniorwr' exists, updating..."
    cd sourcecodeseniorwr
    git pull
else
    git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git
    cd sourcecodeseniorwr
fi
sudo mysql  accounts < src/main/resources/db_backup.sql

sudo systemctl restart mariadb

echo "DB01 setup complete."

