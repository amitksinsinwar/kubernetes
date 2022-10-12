To setup a Kubernetes Cluster using `kubeadm`, you need three servers where one server will act has master server (run control plane) and another two servers will work as worker node. I am going to use Ubuntu 20.04 Focal LTS as an operating system. 

Install the three servers (VM or Baremetal) and set hostnames as respectively.

* kubeadm-node-01
* kubeadm-node-02
* kubeadm-node-03

you can set the hostname on server using the following command.
```shell
hostnamectl kubeadm-node-01
```

Configure `/etc/hosts` file to resolve server names locally.

```shell
vim /etc/hosts
<IP> kubeadm-node-01
<IP> kubeadm-node-02
<IP> kubeadm-node-03
```

Enable kernel modules on each node

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Enabled modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Set kernel parameters
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

## Install containerd 

```shell
# Install containerd
sudo apt update  && sudo apt install -y containerd

# Make configuration directory
sudo mkdir /etc/cotnainerd

# Generate default configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Start the containerd service
sudo systemctl restart containerd

# Verify that containerd is runnig
sudo systemctl status containerd
```

## Make sure the disable swap
```shell
sudo swapoff -a
```

## Install dependencies packages
```shell
sudo apt update && sudo apt install -y apt-transport-https curl
```

## Download the Google Cloud Public Signing key
```shell
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

## Add the Kubernetes `apt` repository 
```shell
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

## Update the `apt` package index, kubeadm, kubectl and kubelet and pin their version. 
```shell
sudo apt update 
sudo apt install -y kubeadm kubelet kubectl 
sudo apt-mark hold kubeadm kubelet kubectl
```

By default, this will install latest version of `kubeadm`, `kubelet` and `kubectl`. if you want to install specific version of `kubeadm`, `kubelet` and `kubectl`, then find the versions and provide specific version.

```shell
sudo apt-cache madison kubeadm
   kubeadm |  1.25.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.25.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.25.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.6-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.5-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.4-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.3-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.24.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm | 1.23.12-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm | 1.23.11-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm | 1.23.10-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages


sudo apt-cache madison kubectl
   kubectl |  1.25.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.25.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.25.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.6-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.5-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.4-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.3-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl |  1.24.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl | 1.23.12-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl | 1.23.11-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubectl | 1.23.10-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   
   sudo apt-cache madison kubelet
   kubelet |  1.25.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.25.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.25.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.6-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.5-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.4-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.3-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.2-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.1-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet |  1.24.0-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet | 1.23.12-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet | 1.23.11-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubelet | 1.23.10-00 | https://apt.kubernetes.io kubernetes-xenial/main amd64 Packages

```

Install the same version of all packages. So I am going to install `1.24.0-00`

```shell
$ sudo apt install kubeadm=1.24.0-00 kubelet=1.24.0-00 kubectl=1.24.0-00
```

Verify the `kubeadm` version

```shell
$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"24", GitVersion:"v1.24.0", GitCommit:"4ce5a8954017644c5420bae81d72b09b735c21f0", GitTreeState:"clean", BuildDate:"2022-05-03T13:44:24Z", GoVersion:"go1.18.1", Compiler:"gc", Platform:"linux/amd64"}
```

## Bootstrap the cluster