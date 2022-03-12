#!/usr/bin/env bash

echo "### apply-gocd.sh"
set -x #echo on

helm repo add gocd https://gocd.github.io/helm-chart
helm repo update

kubectl create ns gocd

helm install gocd stable/gocd \
  --namespace gocd \
  --set server.ingress.enabled=false \
  --set server.ingress.path=gocd \
  --set server.persistence.enabled=false \
  --set agent.persistence.enabled=false


