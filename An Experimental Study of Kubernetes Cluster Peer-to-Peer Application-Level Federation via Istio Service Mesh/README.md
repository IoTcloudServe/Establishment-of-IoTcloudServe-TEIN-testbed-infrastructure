# Setup guide for application-level federation via Istio service mesh

The result of these configurations is the Istio gateway that behaves like a cross-cluster load balancer, by which the overflown traffic is redirected to another cloud. The overflown conditions can be controlled by parameters in the destination rule

For instance, in a scenario where there are two Kubernetes clusters: cluster 1 and cluster 2. If there is a request calling a service in cluster 1 (hereafter “service A”) when there is a burst in demand of service A and resource in the local cluster (cluster 1) is insufficient, users can replicate the service A and deploy it in a remote cluster (cluster 2) as a service B, then redirect the incoming requests to service B. Although this redirect process could be done manually by configuring the virtual service of service A, we propose a method where this redirect process occurs automatically when the number of requests reaches a certain threshold set in destination rule. This method utilizes the locality load balancing functionality of Istio. In particular, when the service A is marked as unhealthy, i.e., incoming requests reaches a certain threshold, the service will be ejected from connection pool and the Istio gateway of cluster 1 will automatically redirect requests to another endpoint of service A. And we can set this endpoint to be service B by creating service entry of service A in cluster 1 pointing to the gateway of cluster 2 (This gateway will forward requests to service B). 

### A.	Install Istio on both clusters
1) Start by creating namespace for Istio

`kubectl create ns istio-system`

2) Create a common root CA

`kubectl create secret generic cacerts -n istio-system \
    --from-file=certs/ca-cert.pem \
    --from-file=certs/ca-key.pem \
    --from-file=certs/root-cert.pem \
    --from-file=certs/cert-chain.pem
`

3) Create a helm value configuration file as config.yaml
```
global:
    multiCluster:
      enabled: true
    mtls:
      enabled: true
    controlPlaneSecurityEnabled: true
security:
    selfSigned: false
```
4) Assuming that users already downloaded Istio helm chart from Istio official website, apply the helm chart with the config.yaml

`helm template ./istio-init  --namespace istio-system --name istio-init  > istio-init.yaml`
`helm template ./istio --namespace istio-system --name istio --values config.yaml > istio.yaml`
`kubectl -n istio-system apply -f istio-init.yaml`
`kubectl -n istio-system apply -f istio.yaml`

5) Enable auto injection in default namespace by labeling the namespace

`kubectl label namespace default istio-injection=enabled`

### B.	Setup cluster 1
1) Set up gateway allowing HTTP /TLS ingress traffic

`kubectl apply -f ingress-gw.yaml`

2) Deploy echo servers

`kubectl apply -f echo-service.yaml `

3) Create virtualservice for echo

`kubectl apply -f echo-vs.yaml`

4) Assign service entry for echo, pointing to ingress gateway of cluster2

`kubectl apply -f echo-entry.yaml`

5) Create destination rule for echo. The field “connectionPool” in destination rule allows users to set their maximum ingress traffic threshold. 
After creating destination rule file as echo-dr.yaml, run the following bash command

`kubectl apply -f echo-dr.yaml`

### C.	Setup cluster 2

1) Set up gateway allowing HTTP/TLS ingress traffic

`kubectl apply -f ingress-gw.yaml`

2) Deploy echo servers

`kubectl apply -f echo-service.yaml`

3) Create virtualservice for echo

`kubectl apply -f echo-vs.yaml`

After following these steps, users should have clusters running as described above.




