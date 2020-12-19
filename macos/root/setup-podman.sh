#!/bin/sh
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
apk add crun podman
echo "::respawn:/usr/bin/podman system service --time=0 tcp:0.0.0.0:58080" >> /etc/inittab
echo "export CONTAINER_HOST=tcp://$(ip -o addr show | awk '{ print $4 }' | cut -d'/' -f1):58080"
reboot
