#!/bin/bash

# VARIABLES #######################################################
# Packages to install
PACKAGES_TO_INSTALL=(
	docker.io
	virt-manager
	virtualbox
	openssh-server
	htop
	epiphany-browser
	neovim
)

# Users
USERS=(
	kelvinra
	ozorio
	diogo
	rondon
	severiano
	james
)
###################################################################

# HANDLING WITH THE SYSTEM ########################################
# Upgrade
sudo apt update
sudo apt upgrade -y

# Installing packages
for package in ${PACKAGES_TO_INSTALL[@]}; do
	if ! dpkg -l | grep -q $package; then # Only install if the package isn't on the system
		sudo apt install $package -y
	else
		echo "$package ALREADY INSTALLED"
	fi
done

# Creating users
for user in ${USERS[@]}; do
	sudo adduser $user
	sudo usermod -aG sudo $user
done
sudo usermod -aG libvirt ${USERS[0]}

# Installing NodeJS and npm
# Removing possible old versions
sudo apt-get remove --purge nodejs
sudo apt-get remove --purge npm
sudo rm -rf ~/.npm
sudo rm -rf /usr/local/lib/node_modules
sudo apt autoremove -y
sudo apt install nodejs npm -y
sudo npm install -g n
sudo n stable
cd /tmp/
curl -0 -L https://npmjs.org/install.sh | sudo sh
###################################################################

# FINISHING #######################################################
sudo apt update
sudo apt autoclean
sudo apt autoremove -y
echo "If possible, reboot the server!"
echo "All done! Now configure the static IP."
###################################################################