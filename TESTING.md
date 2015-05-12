# Testing

## Build Docker image

Note: make and make install must be run first

```
docker build -t mesosphere/kubernetes-mesos .
```

## Run Docker container

The Dockerfile includes everything needed to run a development instance of kubernetes-mesos, including etcd and mesos.

### Background mode

```
docker run --name kubernetes-mesos -p 8888:8888 -p 5050:5050 -p 4001:4001 mesosphere/kubernetes-mesos &> /tmp/kubernetes-mesos-docker.log &
```

## Interactive mode

```
docker run --name kubernetes-mesos -p 8888:8888 -p 5050:5050 -p 4001:4001  -i -t --entrypoint=/bin/bash mesosphere/kubernetes-mesos
```

## Stopping

```
docker kill kubernetes-mesos
```

## Start kubernetes-mesos locally (with etcd & mesos)

```
$ ./scripts/start.sh
```

Example output:

```
Kubernetes: 1.2.3.4:8888
Mesos: 1.2.3.4:5050
Etcd: http://localhost:4001
Config: /Users/<you>/go/src/github.com/mesosphere/kubernetes-mesos/mesos-cloud.conf
Writing default config
Log Dir: /tmp/k8sm-logs
---------------------
Starting etcd
Waiting (up to 10s) for etcd to accept connections
Connection to localhost port 4001 [tcp/newoak] succeeded!
---------------------
Starting mesos-local
Waiting (up to 10s) for mesos-local to accept connections
Connection to 1.2.3.4 port 5050 [tcp/mmcc] succeeded!
---------------------
Starting km apiserver
Waiting (up to 10s) for km apiserver to accept connections
Connection to 1.2.3.4 port 8888 [tcp/ddi-tcp-1] succeeded!
---------------------
Starting km controller-manager
---------------------
Starting km scheduler
---------------------
```