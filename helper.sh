#!/bin/bash

# Function to run command with retries
run_with_retry() {
    local cmd="$@"
    local retries=3
    local delay=5
    local count=0

    until $cmd; do
        ((count++))
        if [ $count -lt $retries ]; then
            echo "Command failed. Retrying in $delay seconds..."
            sleep $delay
        else
            echo "Command failed after $retries retries."
            return 1
        fi
    done
}


# Commands to run in the background
command1='kubectl -n metric-services port-forward '$(kubectl get pods --namespace metric-services -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")' 3000'
command2="minikube tunnel"
# command3="your_command_3"

# Run commands in background with retry
run_with_retry $command1 &
run_with_retry $command2 &
# run_with_retry $command3 &

# Wait for all background processes to finish
wait