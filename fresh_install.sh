#bin/bash

# Check for root as there's quite some sudo commands
if [ "$EUID" > 0 ]
  then echo "Please run as root"
  exit
fi

# Select which parts to execute
echo "### Raspberry Home Setup ###"
echo "1. Mount NAS"
echo "2. Update system"
echo "3. Install docker"
echo "4. Install dc stack service"
echo "5. Install backup cron job"
echo "6. All of the above"
read -p "Choice: " FLOW_CHOICE

# Mount the NAS drive to the raspberry pi
if [ $FLOW_CHOICE = "1" ] || [ $FLOW_CHOICE = "6" ]
then
  echo "Mounting NAS"
  read -p "Enter NAS IP: " NAS_IP
  sudo mkdir /mnt/NAS
  sudo echo "$NAS_IP:/volume1/Media /mnt/NAS nfs defaults 0 1" >> /etc/fstab
  sudo mount -a
fi

# Update and install
if [ $FLOW_CHOICE = "2" ] || [ $FLOW_CHOICE = "6" ]
then
  echo "Updating packages"
  sudo apt-get update
  sudo apt-get upgrade -y
fi

# Install docker
if [ $FLOW_CHOICE = "3" ] || [ $FLOW_CHOICE = "6" ]
then
  echo "Installing docker ..."

  curl -sSL https://get.docker.com | sh
  sudo usermod -aG docker abel

  sudo apt-get install libffi-dev libssl-dev
  sudo apt install python3-dev
  sudo apt-get install -y python3 python3-pip
  sudo pip3 install docker-compose
fi

# Set up the systemd service to start the docker-compose file
if [ $FLOW_CHOICE = "4" ] || [ $FLOW_CHOICE = "6" ]
then
  echo "Downloading all images"
  docker-compose up --no-start
  
  echo "Setting up systemctl for docker-compose file"
  # next using the defined path, create the service to always boot the compose file
  # Use cat to read the systemd service file and pipe it to sed
  cat docker-compose.service | sed "s|%I|$(pwd)|g" > /tmp/docker-compose.service
  sudo mv /tmp/docker-compose.service /etc/systemd/system/docker-compose.service

  sudo systemctl daemon-reload
  sudo systemctl enable docker-compose.service
  sudo systemctl start docker-compose.service
fi

# Set up the daily backup for the service config files
if [ $FLOW_CHOICE = "5" ] || [ $FLOW_CHOICE = "6" ]
then
  echo "Adding backup script to cron..."
  (crontab -l ; echo "0 0 * * * $(pwd)/backup/backup-script.sh") | crontab -
fi

echo "Finished setup."
