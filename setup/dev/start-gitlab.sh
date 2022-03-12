#!/usr/bin/env bash

echo "### start-gitlab.sh"
set -x #echo on

DNS_NAME=${1-"gitlab.mlops"}
DATA_PATH=${2-"/data/gitlab"}
GITLAB_ROOT_PASSWORD=${3-"ChangeMe!"}
DOCKER_IMAGE=${4-"gitlab/gitlab-ce:14.7.3-ce.0"}
CACHE_PATH=${5-"/vagrant/docker"}
ROOT_CERTS_PATH=${6-"/usr/local/bin/setup/config/certs"}
REGISTRATION_TOKEN=${7-"GmTMZbtrsYY8Tmb-6QJk"}

CERTS_PATH="${DATA_PATH}/config/ssl"
mkdir -p "${CERTS_PATH}"

if [[ ! -f "${CERTS_PATH}/${DNS_NAME}.crt" ]]; then
  /usr/local/bin/setup/certs/root-certs.sh "${DNS_NAME}" "${ROOT_CERTS_PATH}"
  /usr/local/bin/setup/certs/certs.sh "${DNS_NAME}" "${CERTS_PATH}" "${ROOT_CERTS_PATH}"
fi

load-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

docker stop gitlab && docker rm gitlab

docker run \
  --detach --restart unless-stopped \
  --name gitlab \
  --hostname gitlab \
  --network host \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'https://${DNS_NAME}/'; gitlab_rails['lfs_enabled'] = true; letsencrypt['enable'] = false;" \
  --env GITLAB_ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD}" \
  --env GITLAB_SHARED_RUNNERS_REGISTRATION_TOKEN="${REGISTRATION_TOKEN}" \
  --env GITLAB_TIMEZONE="Asia/Seoul" \
  --volume "${DATA_PATH}/config:/etc/gitlab" \
  --volume "${DATA_PATH}/logs:/var/log/gitlab" \
  --volume "${DATA_PATH}/data:/var/opt/gitlab" \
  "${DOCKER_IMAGE}"

save-docker-image.sh "${DOCKER_IMAGE}" "${CACHE_PATH}"

# wait for gitlab init.
echo "wait for gitlab init. (3 mins)"
sleep 180
