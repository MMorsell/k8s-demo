#!/bin/bash
sudo apt-get update
sudo apt-get install vim parallel -y

# recreate and start k8s cluster
minikube delete --all
minikube start --memory 8000 --cpus 4 --driver=docker

# install and deploy prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace metric-services --create-namespace

# install and deploy grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus-operator-crds prometheus-community/prometheus-operator-crds
helm install grafana grafana/grafana --namespace metric-services --create-namespace
kubectl patch secret grafana --namespace metric-services -p '{"data":{"admin-password":"'$(echo -n "password" | base64)'"}}'

cd ./telemetry-api/
# pre-build images and load them into minikube
bash build_images.sh

# Deploy v1 pods
kubectl apply -f telemetry-api-deployment-v1.yaml

echo "All done!"