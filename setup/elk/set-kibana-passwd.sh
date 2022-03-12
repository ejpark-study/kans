#!/usr/bin/env bash

echo "### set-kibana-password.sh"
set -x #echo on

ELASTIC_AUTH=${1-"elastic:ChangeMe!"}
KIBANA_PASSWORD=${2-"ChangeMe!"}
ELASTIC_URL=${3-"https://elasticsearch1.mlops:9200"}

curl -k -u "${ELASTIC_AUTH}" -H 'Content-Type: application/json' \
  -d '{"password": "'"${KIBANA_PASSWORD}"'"}' "${ELASTIC_URL}/_security/user/kibana_system/_password"
