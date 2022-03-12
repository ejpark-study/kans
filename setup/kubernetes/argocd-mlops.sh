#!/usr/bin/env bash

echo "### argocd-mlops.sh"
set -x #echo on

GIT_URL=${1-"https://192.168.56.10/avi/helm.git"}
GIT_USERNAME=${2-"root"}
GIT_PASSWORD=${3-"ChangeMe!"}
ARGO_PASSWORD=${4-"ChangeMe!"}
NAMESPACE=${5-"avi"}
GIT_PATH=${6-"labeling-tool"}
APP_NAME=${7-"labeling-tool"}

ARGO_SERVER_IP=$(kubectl get svc/argocd-server -n argocd -o json | jq .status.loadBalancer | grep ip | cut -f2 -d':' | cut -f2 -d'"')
argocd login --username admin --password "${ARGO_PASSWORD}" --insecure "${ARGO_SERVER_IP}"

argocd repo add "${GIT_URL}" \
  --upsert \
  --name mlops \
  --username "${GIT_USERNAME}" \
  --password "${GIT_PASSWORD}" \
  --insecure-ignore-host-key \
  --insecure-skip-server-verification

argocd app create "${APP_NAME}" \
  --upsert \
  --self-heal \
  --repo "${GIT_URL}" \
  --revision HEAD \
  --path "${GIT_PATH}" \
  --project default \
  --dest-namespace "${NAMESPACE}" \
  --dest-server https://kubernetes.default.svc \
  --sync-policy auto \
  --sync-option CreateNamespace=true

argocd app list

# argocd app delete labeling-tool --yes
# argocd repo rm https://192.168.56.10/avi/helm.git
# ssh-keyscan gitlab.mlops | argocd cert add-ssh --batch
