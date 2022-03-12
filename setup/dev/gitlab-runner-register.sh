#!/usr/bin/env bash

echo "### gitlab-runner-register.sh"
set -x #echo on

DNS_NAME=${1-"gitlab.mlops"}
REG_TOKEN=${2-"GmTMZbtrsYY8Tmb-6QJk"}

docker exec -t gitlab-runner \
  gitlab-runner register \
    --non-interactive \
    --name runner \
    --url "https://${DNS_NAME}" \
    --registration-token "${REG_TOKEN}" \
    --executor "docker" \
    --docker-image alpine:latest \
    --run-untagged \
    --locked="false" \
    --env "GIT_SSL_NO_VERIFY=1" \
    --docker-privileged \
    --docker-pull-policy if-not-present \
    --docker-network-mode host \
    --docker-volumes '/var/run/docker.sock:/var/run/docker.sock'

# ref: https://docs.gitlab.com/runner/register/