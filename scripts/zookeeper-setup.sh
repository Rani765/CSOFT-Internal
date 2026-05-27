#!/bin/bash
set -e

# Variables from Terraform
ZK_ID=${ZK_ID}
ZK_NODES=${ZK_NODES}
EFS_ID=${EFS_ID}
AWS_REGION=${AWS_REGION}

# Update system
apt-get update -y
apt-get upgrade -y

# Install dependencies
apt-get install -y default-jdk wget nfs-common awscli

# Create zookeeper user
useradd -m -s /bin/bash zookeeper || true

# Mount EFS
mkdir -p /mnt/efs
echo "$${EFS_ID}.efs.$${AWS_REGION}.amazonaws.com:/ /mnt/efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# Wait for EFS to be available and mount
sleep 30
mount -a || mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $${EFS_ID}.efs.$${AWS_REGION}.amazonaws.com:/ /mnt/efs

# Create Zookeeper directories
mkdir -p /mnt/efs/zookeeper/node-$${ZK_ID}
mkdir -p /opt/zookeeper
mkdir -p /var/log/zookeeper

# Download and install Zookeeper
ZK_VERSION="3.8.4"
wget -q "https://dlcdn.apache.org/zookeeper/zookeeper-$${ZK_VERSION}/apache-zookeeper-$${ZK_VERSION}-bin.tar.gz" -O /tmp/zookeeper.tar.gz
tar -xzf /tmp/zookeeper.tar.gz -C /opt/zookeeper --strip-components=1
rm -f /tmp/zookeeper.tar.gz

# Set Zookeeper data directory
ZK_DATA_DIR="/mnt/efs/zookeeper/node-$${ZK_ID}"

# Create myid file
echo "$${ZK_ID}" > $${ZK_DATA_DIR}/myid

# Create Zookeeper configuration
cat > /opt/zookeeper/conf/zoo.cfg <<EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=$${ZK_DATA_DIR}
clientPort=2181
maxClientCnxns=60
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
admin.enableServer=true
admin.serverPort=8080

# Cluster configuration
server.1=zk1.csoft.internal:2888:3888
server.2=zk2.csoft.internal:2888:3888
server.3=zk3.csoft.internal:2888:3888
EOF

# Set permissions
chown -R zookeeper:zookeeper /opt/zookeeper
chown -R zookeeper:zookeeper /mnt/efs/zookeeper/node-$${ZK_ID}
chown -R zookeeper:zookeeper /var/log/zookeeper

# Create systemd service
cat > /etc/systemd/system/zookeeper.service <<EOF
[Unit]
Description=Apache Zookeeper
Documentation=https://zookeeper.apache.org
After=network.target remote-fs.target

[Service]
Type=forking
User=zookeeper
Group=zookeeper
Environment="JAVA_HOME=/usr/lib/jvm/default-java"
ExecStart=/opt/zookeeper/bin/zkServer.sh start
ExecStop=/opt/zookeeper/bin/zkServer.sh stop
ExecReload=/opt/zookeeper/bin/zkServer.sh restart
Restart=on-failure
RestartSec=10
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Zookeeper
systemctl daemon-reload
systemctl enable zookeeper
systemctl start zookeeper

# Install SSM Agent
snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

echo "Zookeeper Node $${ZK_ID} setup complete"
