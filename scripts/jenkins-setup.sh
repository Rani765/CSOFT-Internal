#!/bin/bash
set -e

# Update system
sudo apt update -y

# Install Java 21
sudo apt install -y fontconfig openjdk-21-jre

# Verify Java
java -version

# Add Jenkins repo key and source
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Install SSM Agent
sudo snap install amazon-ssm-agent --classic || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

echo "Jenkins setup complete"
