#!/bin/bash

DEBIAN_FRONTEND=noninteractive apt-get -qqy update
DEBIAN_FRONTEND=noninteractive apt-get install -y jq \
    git \
    ssh-import-id \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    unzip

# Install Docker    

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

DEBIAN_FRONTEND=noninteractive apt-get -qqy update

DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


cat <<EOF > /opt/traefik-docker-compose.yml
version: '3'

services:
  reverse-proxy:
    # The official v3 Traefik docker image
    image: traefik:v3.1
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    restart: unless-stopped
    labels:
      - "traefik.http.routers.dashboard.rule=Host(`traefik./"${pdns_zone}/"`)"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
  whoami:
    # A container that exposes an API to show its IP address
    image: traefik/whoami
    restart: unless-stopped
    labels:
      - "traefik.http.routers.whoami.rule=Host(`whoami./"${pdns_zone}/"`)"
EOF

docker-compose -f /opt/traefik-docker-compose.yml up -d
