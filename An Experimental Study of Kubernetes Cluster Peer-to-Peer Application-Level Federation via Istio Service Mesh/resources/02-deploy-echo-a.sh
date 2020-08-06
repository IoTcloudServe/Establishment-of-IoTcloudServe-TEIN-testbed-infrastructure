source 00-common.sh
set -x
######in cluster 1################
#set up gateway (allow http/tls ingress traffic)
kubectl apply -f ingress-gw.yaml
#deploy echo service
kubectl apply -f echo-service.yaml
#create virtualservice for splitting traffic
kubectl apply -f echo-vs.yaml
#assign service entry for echo, pointing to ingress gateway of cluster2
kubectl apply -f echo-entry-a.yaml 
#create destination rules
kubectl apply -f echo-dr-a.yaml 
