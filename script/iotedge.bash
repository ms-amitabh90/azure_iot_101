wget https://packages.microsoft.com/config/ubuntu/18.04/multiarch/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update; \
  sudo apt-get install moby-engine -y

sudo apt-get update; \
  sudo apt-get install aziot-edge defender-iot-micro-agent-edge -y

sudo iotedge config mp --connection-string 'connection string'

sudo iotedge config apply