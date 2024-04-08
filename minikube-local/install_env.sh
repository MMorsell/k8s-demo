#!/bin/bash


# wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
# sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
# sudo apt-get update
# sudo apt-get install google-chrome-stable

minikube delete --all 
minikube start --nodes 2 -p minikube
minikube addons enable helm-tiller
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 
helm repo update 
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack 
kubectl expose service kube-prometheus-stack-prometheus --type=NodePort --target-port=9090 --name=prometheus-node-port-service 
kubectl expose service kube-prometheus-stack-grafana --type=NodePort --target-port=3000 --name=grafana-node-port-service

# google-chrome-stable --headless --remote-debugging-port=9222


# https://medium.com/@gayatripawar401/deploy-prometheus-and-grafana-on-kubernetes-using-helm-5aa9d4fbae66   