#!/usr/bin/env bash

# This script install required packages and dependencies required for a node while installation Kubernetes cluster using Kubeadm.
# This script will install version 1.24.0 of kubeadm, kubelet and kubectl by default, you can update the version number or remove to 
# version numbers for the latest packages.

echo "Enabling the Kernel Modules and parameters"

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo "installing and configuring containerd"

sudo apt update  && sudo apt install -y containerd
sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl status containerd

echo "Disabling swap"
sudo swapoff -a

echo "Installing dependencies packages"
sudo apt update && sudo apt install -y apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing Kubeadm kubelet and kubectl"
sudo apt update
sudo apt install -y kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00






