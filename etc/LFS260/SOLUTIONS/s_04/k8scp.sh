#!/bin/bash
#/* **************** LFS460:1.23.1-u1 s_04/k8scp.sh **************** */
#/*
# * The code herein is: Copyright the Linux Foundation, 2022
# *
# * This Copyright is retained for the purpose of protecting free
# * redistribution of source.
# *
# *     URL:    https://training.linuxfoundation.org
# *     email:  info@linuxfoundation.org
# *
# * This code is distributed under Version 2 of the GNU General Public
# * License, which you should have received with the source.
# *
# */
#!/bin/bash -x
## TxS 03-2022
## v1.23.1 CKA/CKAD/CKS
## v1.26.1 CKS - FRK - 02-2023
echo "This script is written to work with Ubuntu 20.04"
sleep 3
echo
echo "Disable swap until next reboot"
echo
sudo swapoff -a

echo "Updating the local node, please stand-by"
sudo apt-get update && sudo apt-get upgrade -y
echo

echo "Ensure two modules are loaded after reboot"

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sleep 2

echo "Load the modules now"

sudo modprobe overlay

sudo modprobe br_netfilter

sleep 2

echo "Update sysctl to load iptables and ipforwarding"

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


sleep 2
echo "Install some necessary software"
sudo apt-get install curl apt-transport-https vim git wget gnupg2 software-properties-common lsb-release ca-certificates uidmap -y

sleep 2

echo "Install and configure containerd"
sleep 2

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update &&  sudo apt-get install containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo systemctl restart containerd


echo
echo "Install kubeadm, kubelet, and kubectl"
sleep 2

sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"

sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"

sudo apt-get update

sudo apt-get install -y kubeadm=1.26.1-00 kubelet=1.26.1-00 kubectl=1.26.1-00

sudo apt-mark hold kubelet kubeadm kubectl


## If you are going to use a different plugin you'll want
## to use a different IP address, found in that plugins
## readme file.

sleep 3

## This assumes you are not using 192.168.0.0/16 for your host
sudo kubeadm init --kubernetes-version 1.26.1 --pod-network-cidr 192.168.0.0/16 | sudo tee /var/log/kubeinit.log

sleep 5

echo "Running the steps explained at the end of the init output for you"

mkdir -p $HOME/.kube

sleep 2

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sleep 2

sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Apply Calico network plugin from ProjectCalico.org"
echo "If you see an error they may have updated the yaml file. Use a browser, navigate to the site and find the updated file "
echo
echo


kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

echo
echo
sleep 15
echo "You should see this node in the output below"
echo "It can take up to a minute for node to show Ready status"
echo
kubectl get node
echo

echo
echo "Script finished. Move to the next step"

