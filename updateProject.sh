#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Hostname, AP interface config, AP name   ####
####    Author : Charles Maheu                     ####
#######################################################

# Exits if any command fails
set -e
# Redirect all outputs to a log file
exec 1>>/home/pi/MOvITPlus/firstBootSetup.log 2>&1
#Log date
echo "----------------------------------------------------------"
echo "Current date : $(date)"


#UPDATE SYSTEM CONFIGURATION
#via the argument --config
if [ $1 == "--config" ]; then
    echo "UPDATING SYSTEM CONFIGURATION through '--config' argument "

    #----------------------------------------
    # INSERT ANY SYS. CONF. SCRIPT HERE 
    echo "No configuration update available"
    #----------------------------------------

    echo "Done updating system configuration"
else


#INITIALISE PROJECT
#via the argument --init
elif [ $1 == "--init" ]; then
    echo "INITIALISING PROJECT though the '--init' argument "

    #----------------------------------------
    # INSERT ANY ADDITIONNAL INIT SCRIPT HERE
    cd /home/pi/MOvIT-Detect-Backend && npm install && cd ..
    node /home/pi/MOvIT-Detect-Backend/initDatabase.js


    systemctl enable
    reboot now #?! NECESSARY ?!
    #----------------------------------------

    echo "Done initialising"
else


#REPOSITORY UPDATE THROUGH GITHUB
#via omission of argument
git pull
git submodule update --init --recursive




fi
exit 0

