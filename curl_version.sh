#!/bin/bash

send_request() {
    curl -s "$(kubectl get service api-lb -o=jsonpath='{.spec.clusterIP}'):8080/version"
}

# Export the function so that parallel can access it
export -f send_request


while true; do
# Run the curl requests in parallel with a factor of 5
    seq 1 5 | parallel -j5 -n0 send_request
done
