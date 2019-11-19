#!/bin/bash
#######################################################
####   MOVIT PLUS Project : update script          ####
####    - Update system configuration              ####
####    - Initialise github project on the device  ####
####    - Update github project on the device      ####
####    Author : Charles Maheu                     ####
#######################################################

# Exits if any command fails
set -e

#Constants---------------------
HomePath="/home/pi"
MovitPath="$HomePath/MOvITPlus"
ConfigArg="--sys-config"
InitArg="--init-project"
GitArg="--git-update"
ConsArg="--console-log"
#------------------------------

if [[ $1 != $ConsArg && $2 != $ConsArg ]]; then
    # Redirect all outputs to a log file
    exec 1>>$HomePath/updateProject.log 2>&1
fi

echo "#######################################################"
echo "Running update script for a Movit plus system"
echo "Current date : $(date)"
echo "#######################################################"

#UPDATE SYSTEM CONFIGURATION
#via the argument $ConfigArg
elif [[ $1 == $ConfigArg || $2 == $ConfigArg ]]; then
    echo "### UPDATING SYSTEM CONFIGURATION through the '$ConfigArg' argument "

    #----------------------------------------
    # INSERT ANY ADDITIONNAL SYSTEM CONFIG SCRIPT HERE 
    echo "No configuration update available..."
    #----------------------------------------

    echo "Done updating system configuration"


#INITIALISE PROJECT
#via the argument $InitArg
elif [[ $1 == $InitArg || $2 == $InitArg ]]; then
    echo "### INITIALISING PROJECT though the '$InitArg' argument "

    #----------------------------------------
    echo "Using Movit folder location : $MovitPath"

    echo "Installing backend modules..."
    cd $MovitPath/MOvIT-Detect-Backend && npm install

    echo "Initialising database..."
    node $MovitPath/MOvIT-Detect-Backend/initDatabase.js
    
    echo "Installing frontend modules..."
    cd $MovitPath/MOvIT-Detect-Frontend && yarn install --production --network-timeout 1000000
    #use of --production must be tested...

    echo "Compiling acquisition software..."
    cd $MovitPath/MOvIT-Detect/bcm2835-1.58 && ./configure && make && sudo make check && sudo make install
    cd $MovitPath/MOvIT-Detect/Movit-Pi && make -f MakefilePI all

    systemctl enable movit_acquisition.service
    systemctl enable movit_frontend.service
    systemctl enable movit_backend.service
    #----------------------------------------

    echo "Done initialising"


#REPOSITORY UPDATE THROUGH GITHUB
#Note : To run this command and successfully update the Git repo with $GitArg, the script must be run as such :
# curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
elif [[ $1 == $GitArg || $2 == $GitArg ]]; then
    echo "### Updating all Git repositories through the '$GitArg' argument"

    #----------------------------------------
    #Update function
    updateGithub () {
        echo "Update available, proceeding..."

        echo "Stopping outdated services..."
        systemctl stop movit_acquisition.service
        systemctl stop movit_frontend.service
        systemctl stop movit_backend.service

        echo "Updating repositories..."
        cd $MovitPath/
        git pull
        git submodule update --init --recursive

        echo "Starting updated services..."
        systemctl start movit_acquisition.service
        systemctl start movit_frontend.service
        systemctl start movit_backend.service
    }

    echo "Using Movit folder location : $MovitPath"
    cd $MovitPath
    #Figuring out if an update is available and calling update function if so
    [ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | sed 's/\// /g') | cut -f1) ] && echo "Already up to date, nothing to do" || updateGithub
    #----------------------------------------

    echo "### Done updating all GitHub repositories"
    echo "Databases and other settings may need to be resetted manually"


else

echo " "
echo "Warning : No arguments passed or invalid arguments!"
echo "Use one of the following :"
echo "   $ConfigArg"
echo "   $InitArg"
echo "   $GitArg"
echo " "
echo "Additionnaly, use '$ConsArg' to redirect logs to the console"
fi

echo "Exiting..."
exit 0

