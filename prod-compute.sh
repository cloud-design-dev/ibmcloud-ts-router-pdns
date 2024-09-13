#!/bin/bash

update_system() {
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get install -y debian-keyring debian-archive-keyring jq git ssh-import-id apt-transport-https ca-certificates curl software-properties-common unzip
}

install_docker() {
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  DEBIAN_FRONTEND=noninteractive apt-get -qqy update
  DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-compose-plugin
  systemctl enable --now docker
}

write_traefik_docker_compose() {
  cat <<EOF > /opt/docker-compose.yml
version: '3'

services:
  reverse-proxy:
    # The official v3 Traefik docker image
    image: traefik:v3.1
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.dashboard=true --api.insecure=true --providers.docker --log.level=DEBUG
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    labels:
    - traefik.http.routers.dashboard.rule=Host("dashboard.${pdns_zone}")
    - traefik.http.services.dashboard.loadbalancer.server.port=8080
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
  whoami:
    # A container that exposes an API to show its IP address
    image: traefik/whoami
    labels:
    - traefik.http.routers.whoami.rule=Host("whoami.${pdns_zone}")
  request-baskets:
    image: darklynx/request-baskets
    labels:
    - traefik.http.routers.requests.rule=Host("requests.${pdns_zone}")
    - traefik.http.services.requests.loadbalancer.server.port=55555
  it-tools:
    image: corentinth/it-tools:latest
    labels:
    - traefik.http.routers.tools.rule=Host("tools.${pdns_zone}")
EOF
}

echo "starting system update"
update_system

echo "installing docker"
install_docker

echo "writing traefik docker-compose"
write_traefik_docker_compose

echo "starting traefik"
docker compose -f /opt/docker-compose.yml up -d

echo "install complete"