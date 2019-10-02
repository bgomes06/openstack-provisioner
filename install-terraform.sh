#!/bin/bash

### Define if fedora/debian base images

egrep -i "ubuntu|debian" /etc/os-release > /dev/null 2>&1

if [ $? == 0 ]; then
	INSTALL_MANAGER="apt"
fi

egrep -i "rhel|fedora|centos" /etc/os-release > /dev/null 2>&1

if [ $? == 0 ]; then
	INSTALL_MANAGER="yum"
fi

echo "Updating packages..."
sudo $INSTALL_MANAGER update -y > /dev/null 2>&1

echo "Packages upgrade done."
sleep 3

echo "Installing required packages..."
sudo $INSTALL_MANAGER install -y wget unzip > /dev/null 2>&1

echo "Required packages installation done."
sleep 3

echo "Download Terraform packages, unzip and move it to bin directory"
export TER_VER="0.12.9"
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip -O /tmp/terraform_${TER_VER}_linux_amd64.zip > /dev/null 2>&1
unzip /tmp/terraform_${TER_VER}_linux_amd64.zip -d /tmp/ > /dev/null 2>&1
sudo mv /tmp/terraform /usr/local/bin/ > /dev/null 2>&1

echo "Terraform installation finished."
sleep 3

echo "Cleaning the mess..."
sudo rm /tmp/terraform_${TER_VER}_linux_amd64.zip > /dev/null 2>&1
echo "##########################################"
echo "Terraform verions: " $(terraform -v)
echo "Finish Terraform installation process."

echo "Key creation process..."

mkdir -p ./key/

ssh-keygen -t rsa -N '' -f ./key/id_rsa

echo "Key creation process finished."
sleep 3

echo "Terraform build environment process"
terraform init
sleep 3
terraform apply
echo "Terraform build finished"
