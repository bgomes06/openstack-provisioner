#!/bin/bash

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network

sudo yum --nogpgcheck localinstall -y https://repos.fedorapeople.org/repos/openstack/openstack-stein/rdo-release-stein-3.noarch.rpm
sudo yum install -y centos-release-openstack-stein
sudo yum-config-manager --enable openstack-stein
sudo yum update -y
sudo yum install -y openstack-packstack
sudo packstack --allinone

source /root/keystonerc_admin
nova flavor-create m1.acctest 99 512 5 1 --ephemeral 10
nova flavor-create m1.resize 98 512 6 1 --ephemeral 10
_NETWORK_ID=$(openstack network show private -c id -f value)
_SUBNET_ID=$(openstack subnet show private_subnet -c id -f value)
_EXTGW_ID=$(openstack network show public -c id -f value)
_IMAGE_ID=$(openstack image show cirros -c id -f value)

echo "" >> /root/keystonerc_admin
echo export OS_IMAGE_NAME="cirros" >> /root/keystonerc_admin
echo export OS_IMAGE_ID="$_IMAGE_ID" >> /root/keystonerc_admin
echo export OS_NETWORK_ID=$_NETWORK_ID >> /root/keystonerc_admin
echo export OS_EXTGW_ID=$_EXTGW_ID >> /root/keystonerc_admin
echo export OS_POOL_NAME="public" >> /root/keystonerc_admin
echo export OS_FLAVOR_ID=99 >> /root/keystonerc_admin
echo export OS_FLAVOR_ID_RESIZE=98 >> /root/keystonerc_admin
echo export OS_DOMAIN_NAME=default >> /root/keystonerc_admin
echo export OS_TENANT_NAME=\$OS_PROJECT_NAME >> /root/keystonerc_admin
echo export OS_TENANT_ID=\$OS_PROJECT_ID >> /root/keystonerc_admin
echo export OS_SHARE_NETWORK_ID="foobar" >> /root/keystonerc_admin

echo "" >> /root/keystonerc_demo
echo export OS_IMAGE_NAME="cirros" >> /root/keystonerc_demo
echo export OS_IMAGE_ID="$_IMAGE_ID" >> /root/keystonerc_demo
echo export OS_NETWORK_ID=$_NETWORK_ID >> /root/keystonerc_demo
echo export OS_EXTGW_ID=$_EXTGW_ID >> /root/keystonerc_demo
echo export OS_POOL_NAME="public" >> /root/keystonerc_demo
echo export OS_FLAVOR_ID=99 >> /root/keystonerc_demo
echo export OS_FLAVOR_ID_RESIZE=98 >> /root/keystonerc_demo
echo export OS_DOMAIN_NAME=default >> /root/keystonerc_demo
echo export OS_TENANT_NAME=\$OS_PROJECT_NAME >> /root/keystonerc_demo
echo export OS_TENANT_ID=\$OS_PROJECT_ID >> /root/keystonerc_demo
echo export OS_SHARE_NETWORK_ID="foobar" >> /root/keystonerc_demo

yum install -y wget
wget -O /usr/local/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
chmod +x /usr/local/bin/gimme
eval "$(/usr/local/bin/gimme 1.8)"
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

go get github.com/gophercloud/gophercloud
pushd ~/go/src/github.com/gophercloud/gophercloud
go get -u ./...
popd

cat >> /root/.bashrc <<EOF
if [[ -f /usr/local/bin/gimme ]]; then
  eval "\$(/usr/local/bin/gimme 1.8)"
  export GOPATH=$HOME/go
  export PATH=\$PATH:$GOROOT/bin:\$GOPATH/bin
fi

gophercloudtest() {
  if [[ -n \$1 ]] && [[ -n \$2 ]]; then
    pushd  ~/go/src/github.com/gophercloud/gophercloud
    go test -v -tags "fixtures acceptance" -run "\$1" github.com/gophercloud/gophercloud/acceptance/openstack/\$2 | tee ~/gophercloud.log
    popd
  fi
}
EOF
