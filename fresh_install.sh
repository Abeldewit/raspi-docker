#bin/bash

# Mount the NAS drive to the raspberry pi
read -p "Enter NAS IP: " NAS_IP
sudo echo "$NAS_IP:/volume1/Media /mnt/NAS nfs defaults 0 1" >> /etc/fstab

# Update and install
sudo apt-get update
sudo apt-get upgrade

# Install docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

sudo systemctl start docker.service

# Set up Docker's Apt repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/raspbian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Set up the systemd service to start the docker-compose file
sudo cat docker-compose.service > /etc/systemd/system/docker-compose.service
sudo systemctl daemon-reload
sudo systemctl enable docker-compose.service
sudo systemctl start docker-compose.service

echo "Finished setup! Docker services are running"
