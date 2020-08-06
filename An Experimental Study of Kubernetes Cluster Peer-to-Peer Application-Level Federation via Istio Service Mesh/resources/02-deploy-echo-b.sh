source 00-common.sh
set -x
######in cluster 2################
#set up gateway (allow http/tls ingress traffic)
kubectl apply -f ingress-gw.yaml 
#deploy echo service
kubectl apply -f echo-service.yaml 
#crate virtualservice to map traffic to service
kubectl apply -f echo-vs.yaml 