#!/bin/bash

echo "K8 Node added as $(whoami)" >> /tmp/k8init

apt-get update
apt-get install -y apt-transport-https curl
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet=1.12.4-00
apt-get install -y kubeadm=1.12.4-00
apt-get install -y kubectl=1.12.4-00
apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
apt-get install -y awscli
apt-get install -y jq
apt-mark hold kubelet kubeadm kubectl docker-ce

# kubelet needs to be stopped
systemctl stop kubelet

# get info from tags

INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
REGION="`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

TAG_INFO=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID")

TOKEN=$(echo $TAG_INFO | jq .[] | jq '.[] | select(.Key=="TOKEN")["Value"]' | tr -d '"')
K8MASTER=$(echo $TAG_INFO | jq .[] | jq '.[] | select(.Key=="K8MASTER")["Value"]' | tr -d '"')

kubeadm join --token $TOKEN --node-name $(hostname -f) --discovery-token-unsafe-skip-ca-verification  $K8MASTER
