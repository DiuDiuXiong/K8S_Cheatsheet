#!/bin/bash
echo "Start setting up first controlplane node. Host: $(hostname)"
sudo apt update && sudo apt upgrade -y

echo "Start to configure container runtime, use docker.io here."
sudo apt install -y docker.io
sudo systemctl enable --now docker

# install kubeadm kubectl kubelet: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#:~:text=Debian%2Dbased%20distributions
sudo apt install -y apt-transport-https ca-certificates curl
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable Swap
echo "Closing swap"
sudo swapoff -a

# Enable IP forwarding
echo "Enable IP forwarding."
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Init K8S Cluster
echo "Init cluster now..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Sharing config to default .kube for kubectl commands
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Install fannel, Pod Network: kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
