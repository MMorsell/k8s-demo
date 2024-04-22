# Dependancies:
- Docker (local desktop)
- Visual studio code
- GIT

## After devcontainer is completely started:
- Launch `./helper.sh` in a seperate console and let it run
- Run `./configure_grafana.sh`

## Useful `kubectl` commands
Get Pods: Lists all pods in the current namespace. Use `-w` to follow changes
`kubectl get pods`

Describe Deployment: Provides detailed information about a specific deployment.
`kubectl describe deployment.apps <deploymentName>`

Apply: configure a new desired state: 
`kubectl apply -f <path-to-yaml-configuration>`

Port Forward: Forwards local ports to a pod’s ports.
`kubectl port-forward <podName> localPort:podPort`


## General architectal structure of k8s
```mermaid
graph TD
  subgraph Cluster
    A[Control Plane]
    B[Node 1]
    C[Node 2]
    D[Node N]
  end

  subgraph Services
    E[Service 1]
    F[Service 2]
    G[Service N]
  end

  subgraph Ingress
    H[Ingress Controller]
    I[Ingress Rules]
  end

  subgraph Pods
    J[Pod 1]
    K[Pod 2]
    L[Pod N]
  end

  subgraph Containers
    M[Container 1]
    N[Container 2]
    O[Container N]
  end

  A --> E
  A --> F
  A --> G
  B --> J
  C --> K
  D --> L
  J --> M
  K --> N
  L --> O
  H --> I
  I --> E
  I --> F
  I --> G
```

## Detailed architectal structure of k8s and the client-pod communication

```mermaid
graph LR;
 client([client])-. Ingress-managed <br> load balancer .->ingress[Ingress];
 ingress-->|routing rule|service[Service];
 subgraph cluster
 ingress;
 service-->pod1[Pod];
 service-->pod2[Pod];
 end
 classDef plain fill:#ddd,stroke:#fff,stroke-width:4px,color:#000;
 classDef k8s fill:#326ce5,stroke:#fff,stroke-width:4px,color:#fff;
 classDef cluster fill:#fff,stroke:#bbb,stroke-width:2px,color:#326ce5;
 class ingress,service,pod1,pod2 k8s;
 class client plain;
 class cluster cluster;

```
