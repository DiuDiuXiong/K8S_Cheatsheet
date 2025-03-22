#!/bin/bash

# Update and upgrade the system
echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker container runtime
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Install Kubernetes components: kubeadm, kubelet, and kubectl
echo "Installing Kubernetes packages (kubeadm, kubelet, kubectl)..."
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable Swap
echo "Disabling swap..."
sudo swapoff -a
# Permanently disable swap by commenting out the swap line in fstab
sudo sed -i '/swap/d' /etc/fstab

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Join the Kubernetes cluster
# Note: Replace <JOIN_COMMAND> with the actual join command provided by the master node.
echo "Joining the Kubernetes cluster..."
sudo kubeadm join 170.64.167.79:6443 --token <your-token> --discovery-token-ca-cert-hash sha256:<your-hash>

# Ensure the kubelet is running
echo "Ensuring kubelet is running..."
sudo systemctl enable kubelet && sudo systemctl start kubelet
