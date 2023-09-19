# RasPI Docker Compose
In this repo, all necessary configurations are stored to setup a clean install of my preferred raspberry pi set-up. 

Using `docker-compose` I configure and run several services in my home. 

# Install and run the container stack
Using the `fresh_install.sh` script, a fresh Raspbian installation can be configured with the docker service, mounting the NAS necessary for the Media Services listed below, and setting up a `systemctl` service to automatically run the stack on boot. 

The IP for the NAS is asked during this script. 

Please change any file-paths in the `docker-compose.service` file to point to the correct `docker-compose.yaml`. 

### Services
- **Radarr**: Movie management
- **Sonarr**: TV management
- **Bazarr**: Subtitle management
- **Jackett**: Torrent indexer
- **Readarr**: Book management
- **Prowlarr**: Indexer management
- **Flaresolverr**: Cloudflare captcha solver (for Jackett)
- **Homebridge**: Extend Apple Homekit with 3rd party appliances 
- **Tailscale**: Personal VPN



