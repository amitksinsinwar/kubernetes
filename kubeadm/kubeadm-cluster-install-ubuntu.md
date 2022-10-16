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

```bash
$ sudo kubeadm init --pod-network-cidr 10.70.0.0/16 --service-cidr 10.99.0.0
```

## Copy the Kubernetes config file for kubectl to normal user

```bash
$ mkdir .kube
$ sudo cp /etc/kubenetes/admin.conf .kube/config
$ sudo chown $(id -u):$(id -g) .kube/config
```

now you can run `kubectl` command to get the required resources information.

```bash
$ kubectl get pods
No resources found in default namespace.

$ kubectl get nodes
NAME              STATUS     ROLES           AGE     VERSION
kubeadm-node-01   NotReady   control-plane   9m54s   v1.24.0
```

## Install Kubernetes Addon or CNI Plugin required for containers
Different network plugins are available, but we are insall Calico

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml -O
```

update the pod network cidr in `custom-resource.yml` file with the cidr you chose during the cluster initialization. We have used the pod network `10.200.0.0/16`.

```bash
sed -i 's/192.168.0.0/10.200.0.0/g' custom-resources.yaml

kubectl apply -f custom-resources.yml
```

# Upgrade Kubernetes Cluster

Find the available version of kubeadm

```bash
$ sudo apt-cache madison kubeadm
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

```

So we will upgrade the kubeadm to `1.25.0-00`. 

```bash
sudo apt-mark unhold kubeadm && \
  sudo apt update && sudo apt install -y kubeadm=1.25.0-00 && \
  sudo apt-mark hold kubeadm
```

```bash
$ kubeadm version 
kubeadm version: &version.Info{Major:"1", Minor:"25", GitVersion:"v1.25.0", GitCommit:"a866cbe2e5bbaa01cfd5e969aa3e033f3282a8a2", GitTreeState:"clean", BuildDate:"2022-08-23T17:43:25Z", GoVersion:"go1.19", Compiler:"gc", Platform:"linux/amd64"}
```

```bash
$ sudo kubeadm upgrade plan
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.24.7
[upgrade/versions] kubeadm version: v1.25.0
[upgrade/versions] Target version: v1.25.3
[upgrade/versions] Latest version in the v1.24 series: v1.24.7

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     2 x v1.24.0   v1.25.3

Upgrade to the latest stable version:

COMPONENT                 CURRENT   TARGET
kube-apiserver            v1.24.7   v1.25.3
kube-controller-manager   v1.24.7   v1.25.3
kube-scheduler            v1.24.7   v1.25.3
kube-proxy                v1.24.7   v1.25.3
CoreDNS                   v1.8.6    v1.9.3
etcd                      3.5.3-0   3.5.4-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.25.3

Note: Before you can perform this upgrade, you have to update kubeadm to v1.25.3.

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________

```

```bash
$ sudo kubeadm upgrade apply v1.25.0
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade/version] You have chosen to change the cluster version to "v1.25.0"
[upgrade/versions] Cluster version: v1.24.7
[upgrade/versions] kubeadm version: v1.25.0
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/prepull] Pulling images required for setting up a Kubernetes cluster
[upgrade/prepull] This might take a minute or two, depending on the speed of your internet connection
[upgrade/prepull] You can also perform this action in beforehand using 'kubeadm config images pull'
[upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.25.0" (timeout: 5m0s)...
[upgrade/etcd] Upgrading to TLS for etcd
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/etcd.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2022-10-15-13-13-10/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests2469333971"
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2022-10-15-13-13-10/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2022-10-15-13-13-10/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moved new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backed up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2022-10-15-13-13-10/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This might take a minute or longer depending on the component/version gap (timeout 5m0s)
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upgrade/postupgrade] Removing the old taint &Taint{Key:node-role.kubernetes.io/master,Value:,Effect:NoSchedule,TimeAdded:<nil>,} from all control plane Nodes. After this step only the &Taint{Key:node-role.kubernetes.io/control-plane,Value:,Effect:NoSchedule,TimeAdded:<nil>,} taint will be present on control plane Nodes.
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.25.0". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

Now upgrade the kubelet, so drain the node sothat new workloads won't be scheduled on the node until uncordoned.

```bash
$ kubectl drain kubeadm-node01 --ignore-daemonsets
node/kubeadm-node01 cordoned
WARNING: ignoring DaemonSet-managed Pods: calico-system/calico-node-4k625, calico-system/csi-node-driver-dbcsr, kube-system/kube-proxy-99jdt
evicting pod tigera-operator/tigera-operator-6bb888d6fc-szf56
evicting pod calico-system/calico-kube-controllers-75fc6d8f5b-88n7k
evicting pod calico-system/calico-typha-5667d45bc6-l8lp4
evicting pod calico-apiserver/calico-apiserver-64cf5c69bd-74czq
evicting pod kube-system/coredns-565d847f94-c2jdx
evicting pod calico-apiserver/calico-apiserver-64cf5c69bd-fhdzp
pod/calico-typha-5667d45bc6-l8lp4 evicted
pod/calico-apiserver-64cf5c69bd-fhdzp evicted
pod/calico-apiserver-64cf5c69bd-74czq evicted
pod/calico-kube-controllers-75fc6d8f5b-88n7k evicted
pod/coredns-565d847f94-c2jdx evicted
pod/tigera-operator-6bb888d6fc-szf56 evicted
node/kubeadm-node01 drained
```

Now upgrade the `kubelet` and `kubectl` to the same version as `kubeadm`

```bash
$ sudo apt-mark unhold kubelet kubectl && sudo apt update && sudo apt install -y kubelet=1.25.0-00 kubectl=1.25.0-00 && sudo apt-mark hold kubelet kubectl
Canceled hold on kubelet.
Canceled hold on kubectl.
Hit:2 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:3 http://security.ubuntu.com/ubuntu focal-security InRelease                  
Get:4 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]           
Hit:1 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
Get:5 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Fetched 222 kB in 2s (140 kB/s)    
Reading package lists... Done
Building dependency tree       
Reading state information... Done
23 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 21 not upgraded.
Need to get 29.0 MB of archives.
After this operation, 2825 kB disk space will be freed.
Get:1 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubectl amd64 1.25.0-00 [9500 kB]
Get:2 https://packages.cloud.google.com/apt kubernetes-xenial/main amd64 kubelet amd64 1.25.0-00 [19.5 MB]
Fetched 29.0 MB in 9s (3364 kB/s)                                                                                                                                           
(Reading database ... 95045 files and directories currently installed.)
Preparing to unpack .../kubectl_1.25.0-00_amd64.deb ...
Unpacking kubectl (1.25.0-00) over (1.24.0-00) ...
Preparing to unpack .../kubelet_1.25.0-00_amd64.deb ...
Unpacking kubelet (1.25.0-00) over (1.24.0-00) ...
Setting up kubectl (1.25.0-00) ...
Setting up kubelet (1.25.0-00) ...
kubelet set on hold.
kubectl set on hold.
```

restart the kubelet processs

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart kubelet
```

Reenable the control plane node back so that the new workloads can become schedulable.

```bash
$ kubectl uncordon kubeadm-node01
node/kubeadm-node01 uncordoned
```

Now control plane node is completely updated. Now start upgrading worker nodes. You have to use the same steps as used to upgrade the control plane node.

```bash
$ sudo apt-mark unhold kubeadm && sudo apt update && sudo apt install kubeadm=1.25.0-00 && sudo apt-mark hold kubeadm
```

```bash
$ sudo kubeadm upgrade node
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
```

Drain the worker node

```bash
$ kubectl drain kubeadm-node02 --ignore-daemonsets
node/kubeadm-node02 already cordoned
Warning: ignoring DaemonSet-managed Pods: calico-system/calico-node-8gbhb, calico-system/csi-node-driver-htnkp, kube-system/kube-proxy-g8mxw
evicting pod tigera-operator/tigera-operator-6bb888d6fc-m8vw9
evicting pod calico-apiserver/calico-apiserver-64cf5c69bd-kxhvz
evicting pod calico-apiserver/calico-apiserver-64cf5c69bd-zzvbw
evicting pod kube-system/coredns-565d847f94-kg2tp
evicting pod calico-system/calico-kube-controllers-75fc6d8f5b-7wkj9
evicting pod calico-system/calico-typha-5667d45bc6-8kxqd
evicting pod kube-system/coredns-565d847f94-g977w
pod/calico-typha-5667d45bc6-8kxqd evicted
pod/tigera-operator-6bb888d6fc-m8vw9 evicted
pod/calico-apiserver-64cf5c69bd-kxhvz evicted
pod/calico-kube-controllers-75fc6d8f5b-7wkj9 evicted
pod/calico-apiserver-64cf5c69bd-zzvbw evicted
pod/coredns-565d847f94-kg2tp evicted
pod/coredns-565d847f94-g977w evicted
node/kubeadm-node02 drained
```

Update the `kubelet` and `kubectl`

```bash
$ sudo apt-mark unhold kubelet kubectl && sudo apt update && sudo apt install kubelet=1.25.0-00 kubectl=1.25.0-00 && sudo apt-mark hold kubelet kubectl
Canceled hold on kubelet.
Canceled hold on kubectl.
Get:2 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Hit:3 http://archive.ubuntu.com/ubuntu focal InRelease                                                             
Hit:1 https://packages.cloud.google.com/apt kubernetes-xenial InRelease                                            
Get:4 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]        
Get:5 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Fetched 336 kB in 2s (174 kB/s)    
Reading package lists... Done
Building dependency tree       
Reading state information... Done
23 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
kubectl is already the newest version (1.25.0-00).
kubelet is already the newest version (1.25.0-00).
0 upgraded, 0 newly installed, 0 to remove and 21 not upgraded.
kubelet set on hold.
kubectl set on hold.

```

Restart the `kubelet` service

```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

Reenable the worker node so that the new workloads can become schedulable.

```shell
kubectl uncordon kubeadm-node02
```

Now you have successfully upgrade the cluster to version `1.25` including control plane and worker node.

