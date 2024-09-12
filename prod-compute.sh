#!/bin/bash

update_system() {
    DEBIAN_FRONTEND=noninteractive apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive apt-get install -y debian-keyring debian-archive-keyring jq git ssh-import-id apt-transport-https ca-certificates curl software-properties-common unzip
}

install_caddy() {
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
  DEBIAN_FRONTEND=noninteractive apt-get -qqy update
  DEBIAN_FRONTEND=noninteractive apt-get install -y caddy
}

echo "starting system update"
update_system

echo "installing caddy"
install_caddy

echo "install complete"