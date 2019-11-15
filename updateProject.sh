#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Hostname, AP interface config, AP name   ####
####    Author : Charles Maheu                     ####
#######################################################

# Exits if any command fails
set -e

if [[ $1 != "--conslog" && $2 != "--conslog" ]]; then
    # Redirect all outputs to a log file
    exec 1>>/home/pi/updateProject.log 2>&1
fi
#Log date
echo "----------------------------------------------------------"
echo "Current date : $(date)"


#UPDATE SYSTEM CONFIGURATION
#via the argument --config
if [[ $1 == "--sysconfig" && $2 == "--sysconfig" ]]; then
    echo "UPDATING SYSTEM CONFIGURATION through the '--config' argument "

    #----------------------------------------
    # INSERT ANY SYSTEM CONFIG SCRIPT HERE 
    echo "No configuration update available"
    #----------------------------------------

    echo "Done updating system configuration"


#INITIALISE PROJECT
#via the argument --init
elif [[ $1 == "--init" && $2 == "--init" ]]; then
    echo "INITIALISING PROJECT though the '--init' argument "

    #----------------------------------------
    # INSERT ANY ADDITIONNAL INIT SCRIPT HERE
    MovitFolder="$(pwd)/MOvITPlus"
    echo "Detected Movit Folder location : $MovitFolder"
    
    echo "Installing backend's modules..."
    cd $MovitFolder/MOvIT-Detect-Backend && npm install
    
    echo "Initialising database..."
    node $MovitFolder/MOvIT-Detect-Backend/initDatabase.js
    
    echo "Installing frontend's modules..."
    cd $MovitFolder/MOvIT-Detect-Frontend && yarn install --network-timeout 1000000

    systemctl enable movit_acquisition.service
    systemctl enable movit_frontend.service
    systemctl enable movit_backend.service

    #CANNOT CALL REBOOT IN UPDATE SCRIPT?
    #reboot now #?! NECESSARY ?!
    #----------------------------------------

    echo "Done initialising"


#SETS CORRECT TIME TO THE RTC
#via the argument --rtctime
elif [[ $1 == "--rtctime" && $2 == "--rtctime" ]]; then
    echo "Setting the correct time to the RTC clock through the '--rtctime'' argument"

    #----------------------------------------
    #Assuming the date and time is correctly set 
    echo "Using '$(date)' and updating hardware clock.."
    sudo hwclock -w --verbose
    
    #CANNOT CALL REBOOT IN UPDATE SCRIPT?
    #reboot now #?! NECESSARY ?!
    #----------------------------------------

    echo "Done setting RTC time"


#REPOSITORY UPDATE THROUGH GITHUB
elif [[ $1 == "--gitupdate" && $2 == "--gitupdate" ]]; then
    echo "Updating all Git repositories through the '--rtctime'' argument"

    #----------------------------------------
    echo "Updating repositories..."
    cd $MovitFolder/
    git pull
    git submodule update --init --recursive
    #----------------------------------------

    echo "Done updating the git repos"




#via omission of argument
else


echo " "
echo "Warning : No arguments passed!"
echo "Use one of the following :"
echo "   --config"
echo "   --init"
echo "   --rtctime"
echo "   --gitupdate"
echo " "
echo "Additionnaly, use '--conslog' to redirect logs to the console"
echo "Exiting..."


fi
exit 0

