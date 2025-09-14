FROM ubuntu:24.04
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y curl sudo wget netcat-openbsd htop vim -y 
RUN curl "https://enterprise.teleportdemo.com:443/scripts/install.sh" | sudo bash
