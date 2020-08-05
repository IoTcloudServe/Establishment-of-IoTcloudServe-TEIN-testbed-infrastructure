source 00-common.sh
set -x
#######for each cluster############
#create namespace for istio
kubectl create ns istio-system
#create keys
kubectl create secret generic cacerts -n istio-system \
    --from-file=certs/ca-cert.pem \
    --from-file=certs/ca-key.pem \
    --from-file=certs/root-cert.pem \
    --from-file=certs/cert-chain.pem
helm template ./istio-init  --namespace istio-system --name istio-init  > istio-init.yaml
helm template ./istio --namespace istio-system --name istio --values ./configs/mutlicluster.yml > istio.yaml
#apply helm template
kubectl -n istio-system apply -f istio-init.yaml
kubectl -n istio-system apply -f istio.yaml
#enable auto injection in default namespace
kubectl label namespace default istio-injection=enabled
