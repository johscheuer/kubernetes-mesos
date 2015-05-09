#!/usr/bin/env bash

set -e
set -x

export SERVICE_HOST=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
export MESOS_MASTER=${SERVICE_HOST}:5050

echo "[mesos-cloud]
    http-client-timeout = 5s
    state-cache-ttl     = 20s
" > ./mesos-cloud.conf

etcd \
  > etcd.log 2>&1 \
  &
SUBPROC_ETCD="$!"

mesos-local \
  > mesos-local.log 2>&1 \
  &
SUBPROC_MESOS="$!"

./bin/km apiserver \
  --address=${SERVICE_HOST} \
  --etcd_servers=http://${SERVICE_HOST}:4001 \
  --portal_net=10.10.10.0/24 \
  --port=8888 \
  --cloud_provider=mesos \
  --cloud_config=./mesos-cloud.conf \
  > apiserver.log 2>&1 \
  &
SUBPROC_API_SERVER="$!"

# wait (up to 10 seconds) until the apiserver is responsive
timeout 10 bash -c "while ! echo exit | nc -z 172.17.0.76 8888; do sleep 0.5; done"

./bin/km controller-manager \
  --master=${SERVICE_HOST}:8888 \
  --cloud_config=./mesos-cloud.conf \
  > controller-manager.log 2>&1 \
  &
SUBPROC_CONTROLLER_MANAGER="$!"

./bin/km scheduler \
  --mesos_master=${MESOS_MASTER} \
  --address=${SERVICE_HOST} \
  --etcd_servers=http://${SERVICE_HOST}:4001 \
  --mesos_user=root \
  --api_servers=${SERVICE_HOST}:8888 \
  > scheduler.log 2>&1 \
  &
SUBPROC_SCHEDULER="$!"

trap "
  echo '--------------------- KILLING PROCESSES'
  set +e
  kill $SUBPROC_SCHEDULER
  kill $SUBPROC_CONTROLLER_MANAGER
  kill $SUBPROC_API_SERVER
  kill $SUBPROC_MESOS
  kill $SUBPROC_ETCD
" SIGTERM SIGINT

wait $SUBPROC_ETCD
wait $SUBPROC_MESOS
wait $SUBPROC_API_SERVER
wait $SUBPROC_CONTROLLER_MANAGER
wait $SUBPROC_SCHEDULER