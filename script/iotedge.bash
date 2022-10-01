#!/bin/bash

curl https://packages.microsoft.com/config/ubuntu/18.04/multiarch/prod.list > ./microsoft-prod.list
sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/
sudo apt-get update
yes | sudo apt-get install moby-engine=19.03.13+azure-1 
yes | sudo apt-get install moby-cli=19.03.13+azure-1
sudo apt-get update
apt list -a iotedge
yes | sudo apt-get install iotedge=1.0.10-1 libiothsm-std=1.0.10-1
sudo mkdir /var/tempdata
sudo mkdir /var/tempdata/tempdata01
sudo mkdir /var/tempdata/tempdata02
sudo adduser -u 1011 --disabled-password --disabled-login --gecos '' moduleuser01
sudo adduser -u 1012 --disabled-password --disabled-login --gecos '' moduleuser02
sudo chown -R azureuser:azureuser /home/moduleuser02/.bashrc
echo "umask 077" >> /home/moduleuser02/.bashrc
sudo chown -R moduleuser02:moduleuser02 /home/moduleuser02/.bashrc
sudo chown -R moduleuser01:moduleuser01 /var/tempdata/tempdata01
sudo chmod -R 770 /var/tempdata/tempdata01
sudo chown -R moduleuser02:moduleuser01 /var/tempdata/tempdata02
sudo chmod -R 770 /var/tempdata/tempdata02