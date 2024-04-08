#!/bin/bash

docker build -t telemetry-api:v1 v1/.
minikube image load telemetry-api:v1

docker build -t telemetry-api:v2 v2/.
minikube image load telemetry-api:v2