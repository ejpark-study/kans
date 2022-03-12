#!/usr/bin/env bash

echo "### apply-argocd.sh"
set -x #echo on

SKEL_PATH=${1:-"/usr/local/bin/setup/config/skel"}

if [[ ! -f "${SKEL_PATH}/argo-cd.yaml" ]]; then
  curl -fsSL -o "${SKEL_PATH}/argo-cd.yaml" "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
fi

if [[ ! -f /usr/local/bin/argocd ]]; then
  ARGO_CLI_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  curl -sSL -o /usr/local/bin/argocd "https://github.com/argoproj/argo-cd/releases/download/${ARGO_CLI_VERSION}/argocd-linux-amd64"
  chmod +x /usr/local/bin/argocd
fi

# start argo cd
kubectl create ns argocd
kubectl apply -n argocd -f "${SKEL_PATH}/argo-cd.yaml"

# change to LoadBalancer
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "ClusterIP"}}'

# turn off tls
kubectl patch configmap argocd-cmd-params-cm -n argocd -p '{"data": {"server.insecure": "true"}}'
kubectl --namespace argocd rollout restart deployment argocd-server

# istio gateway
kubectl apply -f - <<EOF
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
 name: argocd-gateway
 namespace: argocd
spec:
 selector:
   istio: ingressgateway
 servers:
 - hosts:
   - '*'
   port:
     name: http
     number: 80
     protocol: HTTP
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-vs
  namespace: argocd
spec:
  gateways:
  - argocd-gateway.argocd
  hosts:
  - '*'
  http:
  - match:
    - uri:
        prefix: /argocd/
    route:
    - destination:
        host: argocd-server.argocd.svc.cluster.local
        port:
          number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: argocd-server-dtrl
  namespace: argocd
spec:
  host: argocd-server.argocd.svc.cluster.local
  trafficPolicy:
    tls:
      mode: DISABLE
EOF

# isto injection
kubectl label namespace argocd istio-injection=enabled

# wait for argocd init.
echo "Wait for argocd init. (3 mins)"
sleep 180

# test ui
# kubectl port-forward -nargocd deploy/argocd-server --address=0.0.0.0 8081:8080
# kubectl port-forward -nargocd svc/argocd-server --address=0.0.0.0 8081:80

# get initial password
ARGO_PASSWD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo)
ARGO_SERVER_IP=$(kubectl get svc/argocd-server -n argocd -o json | jq .status.loadBalancer | grep ip | cut -f2 -d':' | cut -f2 -d'"')

if [[ "${ARGO_SERVER_IP}" == "" ]]; then
  echo "Cannot find argo-server: ${ARGO_SERVER_IP} ${ARGO_PASSWD}"
  exit 0
fi

# argocd login
argocd login --username admin --password "${ARGO_PASSWD}" --insecure "${ARGO_SERVER_IP}"

# change admin passwd
argocd account update-password --account admin --current-password "${ARGO_PASSWD}" --new-password ChangeMe!

# ref: https://argoproj.github.io/argo-rollouts/getting-started/setup/#istio-setup
# https://velog.io/@borab/Argocd-helm-으로-설치하기
# https://argo-cd.readthedocs.io/en/stable/user-guide/helm/
# https://www.solo.io/blog/gitops-with-argo-cd-and-gloo-mesh-part-1/
