#!/usr/bin/env bash

echo "### kubernetes-join.sh"
set -x #echo on

WORKER_LIST=${1:-"worker1.mlops,worker2.mlops"}

# join worker
for node in ${WORKER_LIST//,/ }; do
  scp /tmp/join.sh "${node}":/tmp/join.sh
  ssh "${node}" "bash /tmp/join.sh"
done

# nodes list
kubectl get nodes -o wide
