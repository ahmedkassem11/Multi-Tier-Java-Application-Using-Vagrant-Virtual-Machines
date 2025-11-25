#!/bin/bash
set -e

# APP01 Provisioning Script

echo "Setting up hosts file..."
cat <<EOF | sudo tee -a /etc/hosts
192.168.56.11 web01
192.168.56.12 app01
192.168.56.13 rmq01
192.168.56.14 mc01
192.168.56.15 db01
EOF

echo "Installing Java, Git, Maven..."
sudo dnf -y install java-11-openjdk java-11-openjdk-devel git maven wget

echo "Downloading and installing Tomcat..."
cd /tmp/
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
sudo cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat

echo "Creating Tomcat systemd service..."
sudo tee -a /etc/systemd/system/tomcat.service <<EOL
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk"
Environment="CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/usr/local/tomcat"
Environment="CATALINA_BASE=/usr/local/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable --now tomcat

echo "Cloning application source code..."
cd /tmp
# Check if directory exists to avoid error
if [ -d "sourcecodeseniorwr" ]; then
    rm -rf sourcecodeseniorwr
fi
git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git

echo "Configuring application properties..."
sudo tee /tmp/sourcecodeseniorwr/src/main/resources/application.properties << EOF
#JDBC Configutation for Database Connection
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://db01:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin123

#Memcached Configuration For Active and StandBy Host
#For Active Host
memcached.active.host=mc01
memcached.active.port=11211
#For StandBy Host
memcached.standBy.host=mc01
memcached.standBy.port=11211

#RabbitMq Configuration
rabbitmq.address=rmq01
rabbitmq.port=5672
rabbitmq.username=guest
rabbitmq.password=guest

#Elasticesearch Configuration
elasticsearch.host =vprosearch01
elasticsearch.port =9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

echo "Building application with Maven..."
cd /tmp/sourcecodeseniorwr
mvn install 

echo "Deploying application to Tomcat..."
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
sudo chown tomcat.tomcat /usr/local/tomcat/webapps -R
sudo systemctl restart tomcat

echo "APP01 setup complete."
