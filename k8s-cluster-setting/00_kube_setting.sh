#!/bin/bash

# basic update
sudo apt-get update -y && sudo apt upgrade -y

# install docker
sudo apt update -y software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update -y
apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo usermod -aG docker $USER

# install docker-compose
# sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# error handling related docker(cgroup)
echo '{ "exec-opts": ["native.cgroupdriver=systemd"], "log-driver": "json-file", "log-opts": { "max-size": "100m" }, "storage-driver": "overlay2" }' | sudo tee /etc/docker/daemon.json > /dev/null

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo rm /etc/containerd/config.toml
sudo systemctl restart containerd

# swap off
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a

# install kubectl
curl -LO https://dl.k8s.io/release/v1.22.15/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo modprobe br_netfilter
echo  "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
echo  "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee /etc/sysctl.d/k8s.conf
echo  "net.bridge.bridge-nf-call-iptables = 1" | sudo tee /etc/sysctl.d/k8s.conf
sudo sysctl --system


# install kubelet, kubeadm
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl &&
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg &&
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list &&
sudo apt-get update
sudo apt-get install -y kubelet=1.22.15-00 kubeadm=1.22.15-00 &&
sudo apt-mark hold kubelet kubeadm kubectl

# modify ip address on your eni
echo -e "\n10.1.1.5 kube-lb" | sudo tee -a /etc/hosts
echo "10.1.1.133 kube-master-1" | sudo tee -a /etc/hosts
echo "10.1.1.165 kube-master-2" | sudo tee -a /etc/hosts
echo "10.1.1.166 kube-master-3" | sudo tee -a /etc/hosts

echo "10.1.1.135 kube-worker-cpu-1" | sudo tee -a /etc/hosts
echo "10.1.1.168 kube-worker-cpu-2" | sudo tee -a /etc/hosts

echo "10.1.1.138 kube-worker-gpu-1" | sudo tee -a /etc/hosts
echo "10.1.1.170 kube-worker-gpu-2" | sudo tee -a /etc/hosts
echo "10.1.1.139 kube-worker-gpu-3" | sudo tee -a /etc/hosts
echo "10.1.1.171 kube-worker-gpu-4" | sudo tee -a /etc/hosts
