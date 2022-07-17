#!/bin/bash

sudo apt-get install -y kubectl
sudo apt-mark hold kubectl
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

kubeadm token create --print-join-command > ~/join.sh

