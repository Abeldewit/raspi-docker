#bin/bash

# Mount the NAS drive to the raspberry pi
echo "Mounting NAS"
read -p "Enter NAS IP: " NAS_IP
sudo echo "$NAS_IP:/volume1/Media /mnt/NAS nfs defaults 0 1" >> /etc/fstab
sudo mount -a

# Update and install
echo "*************************************************"
echo "Updating packages"
sudo apt-get update
sudo apt-get upgrade -y

# Install docker
echo "*************************************************"
echo "Installing docker ..."

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg


# Set up Docker's Apt repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/raspbian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker docker-compose
sudo systemctl start docker.service

# Set up the systemd service to start the docker-compose file
echo "*************************************************"
echo "Setting up systemctl for docker-compose file"

# next using the defined path, create the service to always boot the compose file
# Use cat to read the systemd service file and pipe it to sed
cat docker-compose.service | sed "s|%I|$(pwd)|g" > /tmp/docker-compose.service
sudo mv /tmp/docker-compose.service /etc/systemd/system/docker-compose.service

sudo systemctl daemon-reload
sudo systemctl enable docker-compose.service
sudo systemctl start docker-compose.service

# Set up the daily backup for the service config files
(crontab -l ; echo "0 0 * * * $(pwd)/backup/backup-script.sh") | crontab -

echo "Finished setup! Docker services are running"
