#!/bin/env bash

# VARIABLES #######################################################
# PgAdmin4
PORT="5432"

# Packages to install
PACKAGES_TO_INSTALL=(
	docker.io
	virt-manager
	openssh-server
	htop
	firefox
)

# Docker images
DOCKER_IMAGES=(
	httpd
	nginx
	postgres
	dpage/pgadmin4
)

# Users
USERS=(
	kelvinra
	nascimento
	garcia
	caetano
	ozorio
	diogo
	rondon
	severiano
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
sudo apt install nodejs -y
cd /tmp/
curl -0 -L https://npmjs.org/install.sh | sudo sh

# Installing Heroku
sudo npm install -g heroku
###################################################################

# DOCKER ##########################################################
# Getting docker images
for image in ${DOCKER_IMAGES[@]}; do 
	sudo docker pull $image
done

# POSTGRESQL AND PGADMIN4
# Creating a network for the PostgreSQL and PgAdmin containers
sudo docker network create --driver bridge postgres-network
# Creating a PostgreSQL container
PSQL_PASSWD_LOCK=1
while [ "$PSQL_PASSWD_LOCK" -eq "1" ]
do
	read -s -p 'Enter the Postgres password: ' POSTGRES_PASSWD
	echo
	read -s -p 'Confirm your Postgres password: ' POSTGRES_PASSWD_CONFIRM
	echo
	if [ $POSTGRES_PASSWD == $POSTGRES_PASSWD_CONFIRM ] && [ ! $POSTGRES_PASSWD == "" ] ; then
		echo "Passwords did match!"
		PSQL_PASSWD_LOCK=0
	else
		echo "Invalid passwords, please retype:"
	fi
done
sudo docker run --name bc-postgres --network=postgres-network -e "POSTGRES_PASSWORD=$POSTGRES_PASSWD" -p $PORT:$PORT -v /home/$USER/Desenvolvimento/PostgreSQL:/var/lib/postgresql/data -d postgres

# Creating a PgAdmin container
read -p 'Enter the PgAdmin email: ' PGADMIN_EMAIL
read -p 'Enter the PgAdmin default password: ' PGADMIN_PASSWD
docker run --name bc-pgadmin --network=postgres-network -p 15432:80 -e "PGADMIN_DEFAULT_EMAIL=$PGADMIN_EMAIL" -e "PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASSWD" -d dpage/pgadmin4
# URL: https://localhost:15432/	OR	http://0.0.0.0:15432/

# Font: https://imasters.com.br/banco-de-dados/postgresql-docker-executando-uma-instancia-e-o-pgadmin-4-partir-de-containers

# BACKEND
git clone https://github.com/Senai-Dev-ops/Back.git
cd /Back/backend/
mvn clean package
mvn spring-boot:build-image
sudo docker run -it -p 5000:8080 docker.io/library/dsvendas:0.0.1-SNAPSHOT
cd /tmp/
###################################################################

# FINISHING #######################################################
sudo apt update
sudo apt autoclean
sudo apt autoremove -y
echo "If possible, reboot the server!"
echo "All done! Now configure the static IP."
###################################################################

# NOTES:
# "bc" = bootcamp
