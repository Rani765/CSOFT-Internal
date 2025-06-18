#!/bin/bash
# Usage: ./init.sh <S3_BUCKET_NAME>
#S3_BUCKET_NAME="${1}"
sudo tee /etc/yum.repos.d/mongodb-org.repo << EOF
[mongodb-org]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-8.0.asc
EOF

sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2023/
gpgcheck=1
enabled=1
gpgkey=https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc
EOF

sudo yum -y remove iptables-services
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

sudo dnf -y install epel-release
sudo dnf -y install pritunl mongodb-org pritunl-openvpn
sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl

apt install jq -y
#curl -s https://wm-cloudformation-templates.s3.ap-south-1.amazonaws.com/packages/mongo.sh | bash
touch Pritunl-Credentials.txt
#sudo echo "Below information is a case-sensitive Do not share with any one." > Pritunl-Credentials.txt && sudo pritunl default-password | grep -e 'password: \\|username:' | sed 's/\"//g' >> Pritunl-Credentials.txt
echo "Below information is case-sensitive. Do not share with anyone." | sudo tee Pritunl-Credentials.txt > /dev/null && sudo pritunl default-password | grep -e "password: \|username:" | sed "s/\"//g" | sudo tee -a Pritunl-Credentials.txt
aws s3 cp Pritunl-Credentials.txt s3://${S3_BUCKET_NAME}/client/Pritunl-Credentials.txt

sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service