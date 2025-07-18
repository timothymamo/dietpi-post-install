#!/bin/bash

# Change directory to $[HOME]
pushd ${HOME}

ssh-keygen -a 100 -t ed25519 -f ~/.ssh/id_ed25519
ssh-keygen -a 100 -t rsa -f ${HOME}/.ssh/id_rsa
echo "host github.com
 HostName github.com
 IdentityFile ~/.ssh/id_ed25519" > ${HOME}/.ssh/config

# Set docker autocompletion
mkdir -p ${HOME}/.docker/completions
docker completion zsh > ${HOME}/.docker/completions/_docker

# Set zsh as the default shell for the ${USER}
echo "Settign zsh as default shell for ${USER}"
command -v zsh | sudo tee -a /etc/shells
chsh -s "$(command -v zsh)" ${USER}

cp ${HOME}/.gitconfig-example ${HOME}/.gitconfig
sed -i "s/HOST/${HOST}/g" ${HOME}/.gitconfig

# Start the containers
pushd ${HOME}/docker-compose
docker compose up --detach --wait --wait-timeout 30

# Enable app_sudo for nebula-sync 
sudo sed -i "s/app_sudo = false/app_sudo = true/g" ${HOME}/pihole/etc-pihole/pihole.toml
sudo sed -i "s/listeningMode = \"LOCAL\"/listeningMode = \"ALL\"/g" ${HOME}/pihole/etc-pihole/pihole.toml
sudo sed -i "s/etc_dnsmasq_d = false/etc_dnsmasq_d = true/g" ${HOME}/pihole/etc-pihole/pihole.toml

# Crate a password for the user
sudo passwd ${USER}

# Reboot the system
sudo poweroff --reboot