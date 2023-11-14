# ubuntu-nested-qemu-docker

## Why this strange  idea ?

Because most of docker container can't run in a privileged environment and so cannot run Docker.  
This Docker image runs an Alpine linux in a QEMU virtual machine so the docker daemon runs like in a real machine.

## How to mod

For modding you need **/sources/ubuntu.iso**. It is the official Ubuntu 22.0.4 x64 live server iso. You can find it [at](https://ubuntu.com/download/alternative-downloads) or download it via the official .torrent.  
A copy of the torrent is here… But trusting is something difficulkt :).  

## How to

```sh
docker run -p 5900:5900 -p 8080:80 -p 2323:23 -it -v ./ext:/ext eltorio/ubuntu-nested-qemu-docker  
```

`./ext/entrypoint` is a mandatory shell script. It will be run after all services in the Ubuntu virtual machine.  
From inside the docker container you can log in the qemu guest via `telnet localhost` as runner or root without password.

## Connnect to

You can use vnc on port 5900 (:0) , web vnc on port 80 or telnet on port 23

## Clean

Before packaging this clean was done:

```sh
apt-get clean autoclean
apt-get autoremove --yes
rm -rf /var/lib/{apt,dpkg,cache,log}/
rm -rf /var/log/*
mkdir -p /var/lib/{apt,dpkg,cache,log}/
mkdir -p /var/lib/dpkg/{alternatives,info,parts,triggers,updates}/
touch /var/lib/dpkg/status
echo "" > ~/.bash_history
halt
````

## Demo

For launching busybox:latest in the non privileged image:

```sh
make build
make demo
```

## Connect to nested Alpine

While connected to the qemu container you can reach the nested Alpine vm with

```sh
telnet localhost
```

hit enter and connect as root
For leaving telnet hit CTRL+$ and quit

## Kubernetes sample deployement

This launch 10 replicas of busybox:latest on Kubernetes

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: heartbeat
  namespace: 
type: Opaque
stringData:
  now: "1698685516"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: entrypoint
data:
  entrypoint: |
    #!/bin/sh
    while (! docker stats --no-stream ); do
      # Docker takes a few seconds to initialize
      echo "Waiting for Docker to launch..."
      sleep 1
    done
    docker run -it busybox:latest
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: busybox-tester
  labels:
    app: busybox-tester
spec:
  replicas: 1
  selector:
    matchLabels:
      app: busybox-tester
  template:
    metadata:
      labels:
        app: busybox-tester
    spec:
      containers:
      - name: busybox-tester
        image: eltorio/ubuntu-nested-qemu-docker:latest
        volumeMounts:
        - name: entrypoint
          mountPath: /ext
        env:
          - name: TIMESTAMP
            value: "1698685516"
#        securityContext:
#          privileged: true
      volumes:
      - name: entrypoint
        configMap: 
          name: entrypoint
          defaultMode: 0777
```
