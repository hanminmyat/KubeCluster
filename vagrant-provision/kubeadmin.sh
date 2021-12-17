#!/bin/bash

echo "[Task 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[Task 2] Initailize Kuberntes Cluser"
kubeadm init --apiserver-advertise-address=172.16.1.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[Task 3] Deploy Calico Network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1
mkdir $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown -R $(id -u):$(id -g) $HOME/.kube/

echo "[Task 4] Generate and save cluster join command"
kubeadm token create --print-join-command > /joincluster.sh 2>/dev/null