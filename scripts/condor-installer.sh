#!/bin/bash
set -e
#Set the variable for the os empty for now
PTERO_API_KEY="FYMUQIEAK3b8kuSWuybqYFD20NKWqga3XjdFWBcz3ogAhbbW"
OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
IP=""
RAM=$(free -m | grep "Mem" | awk '{print $2}')
PROVIDER="$1"
LOCATION_ID=$2
#Functions
get_os() {
    if [[ "$OS" == \"Ubuntu* ]]; then
        OS=apt
        log "Running Ubuntu with $OS"
    elif [[ "$OS" == \"Debian* ]]; then
        OS=apt
        log "Running Debian with $OS"
    elif [[ "$OS" == \"Centos* ]]; then
        OS=yum
        log "Running Centos/Red Hat with $OS"
    else
        log "[Error] Not compatible with $OS"
        exit -1
    fi
}
log() {
    echo "[Logger] $1"
    echo "[Logger] $1" >>./install.log
}
get_dependencies() {
    #Check the OS
    get_os
    #Obtain dependencies from packet manager
    if [[ "$OS" == "apt" ]]; then
        # check for curl
        if ! [ -x "$(command -v curl)" ]; then
            log "* curl is required in order for this script to work."
            apt install curl -y
        fi
        if ! [ -x "$(command -v jq)" ]; then
            log "* jq is required in order for this script to work."
            apt install jq -y
        fi

    elif [["$OS" == "yum" ]]; then
        yum install curl jq -y
    else
        log "Not compatible with $OS"
        exit -1
    fi
}
install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        log "Installing docker"
        curl -fsSL https://get.docker.com -o get-docker.sh
        log "Coso docker"
        sh ./get-docker.sh
    else
        log "Docker is already installed!"
    fi
}
enable_cache() {
    log "Enabling cache"
    #Enable cache
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet swapaccount=1"/g' /etc/default/grub
    sudo update-grub
}
discord_log() {
    DISCORD_KEY="$2"
    if [ $DISCORD_KEY = ""]; then
        DISCORD_KEY="https://discordapp.com/api/webhooks/771859147682611220/joGBrKKXglZ-MbX4USLB2X8W5K3mmenIJLP9RCmzoPRdNTkf1SVQzKR7_D5BZIGJw5GV"
    fi
    curl -X POST --data "{\"content\": \"$1\"}" --header "Content-Type:application/json" $DISCORD_KEY
}
install_wings() {
    #Download wings
    mkdir -p /etc/pterodactyl
    curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/v1.0.1/wings_linux_amd64
    chmod u+x /usr/local/bin/wings
    #Obtain and install wings as a service
    curl https://raw.githubusercontent.com/InfinityZ25/scripts/main/condor/wings/wings.service >>/etc/systemd/system/wings.service
    #Enable wings to auto start
    systemctl enable wings.service
    log "Wings has been installed and will start automatically in the next reboot"
}
self_configure_wings() {
    log "Configuring wings..."
    echo " "
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/InfinityZ25/scripts/main/condor/wings/self-install.sh)" " " $PTERO_API_KEY "$PROVIDER-$IP" $LOCATION_ID $IP $RAM
    echo " "
}

#Entry Point of the installer
echo -e "\n****** Condor Installer ******\n"
log "Begun installation at $(TZ=America/New_York date)"
#Obtain public ip
log "Obtaining public ip"
echo " "
IP=$(curl ifconfig.co)
echo " "
#Finish obtaining public ip and log to discord
discord_log "[$PROVIDER] Created a server with ip $IP and ram $RAM"
#Installation
get_dependencies
#Install docker and enable cache
install_docker
enable_cache
#Log midway
discord_log "[$PROVIDER] Installed docker at $IP"
#Pull wings and self configure it
install_wings
self_configure_wings
#Finished instalation
log "Finished installation"
discord_log "[$PROVIDER] Installation finished. Restarting $IP"
#Reboot
sudo systemctl enable docker --now
