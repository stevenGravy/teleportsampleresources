FROM ubuntu:24.04
ARG TELEPORT_CLUSTER_PROXY=${TELEPORT_CLUSTER_PROXY}
ENV TELEPORT_CLUSTER_PROXY=${TELEPORT_CLUSTER_PROXY}
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install curl sudo wget netcat-openbsd htop vim sysstat -y 
RUN curl "https://$TELEPORT_CLUSTER_PROXY/scripts/install.sh" | sudo bash
