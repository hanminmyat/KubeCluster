#!/bin/bash

echo "[Task 1] Disable swap"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[Task 2] Disabel firewall"
ufw disable >/dev/null 2>&1

echo "[Task 3] Enable and Load Kernal Module"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[Task 4] Add Kernel Setting"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system >/dev/null 2>&1

echo "nameserver 8.8.8.8" | tee /etc/resolv.conf >/dev/null 2>&1

echo "[Task 5] Install Containerd runtime"
apt update -qq >/dev/null 2>&1
apt install -qq -y containerd apt-transport-https >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

echo "[Task 6] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[Task 7] Install kubernetes (kubeadm,kubelet, kubectl)"
apt install -qq -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00 >/dev/null 2>&1

echo "[Task 8] Enable ssh password auth"
sed -i "s/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config"
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd_config

echo "[Task 9] Set Root Password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[Task 10] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.1.100 kmaster.example.com kmaster
172.16.1.101 kworker.example.com kworker
EOF