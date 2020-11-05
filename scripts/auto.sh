#!/bin/bash

#Ensure curl is installed
apt install curl jq -y
#Self configure wings
/bin/bash -c "$(curl -fsSL https://4b304e978ed384f1a2c2d3723d59ed5a0f6e8bb2@raw.githubusercontent.com/noobstersmc/Condor-Eggs/main/scripts/condor-installer.sh)" vultr 1
