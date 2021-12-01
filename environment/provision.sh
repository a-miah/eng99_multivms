#!/bin/bash

# update, upgrade, install nginx 
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install nginx -y
sudo systemctl enable nginx  # enables nginx to run


sudo apt-get install python-software-properties -y

# install the required node version - v6
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs

# install npm
sudo npm install pm2 -g
