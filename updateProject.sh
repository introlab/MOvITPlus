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

#Variables---------------------
HomePath="/home/pi"
MovitPath="$HomePath/MOvITPlus"
ConfigArg="--sys-config"
InitArg="--init-project"
GitArg="--git-update"
ConsArg="--console-log"
#------------------------------
#ENV Variables
export PATH=/usr/bin/:$PATH
#source /home/pi/.nvm/nvm.sh #Would reload PATH variable for npm and node but is slow...
export PATH=/home/pi/.nvm/versions/node/v10.16.3/bin/:$PATH #Hardcoding current path instead.
#------------------------------

if [[ $1 != $ConsArg && $2 != $ConsArg ]]; then
    # Redirect all outputs to a log file
    exec 1>>$HomePath/updateProject.log 2>&1
fi

echo ""
echo ""
echo "#######################################################"
echo "Running update script for a Movit plus system"
echo "Lauched with the following arguments : $1 $2 $3"
echo "Current date : $(date)"
echo "#######################################################"

#UPDATE SYSTEM CONFIGURATION
#via the argument $ConfigArg
if [[ $1 == $ConfigArg || $2 == $ConfigArg ]]; then
    echo "### UPDATING SYSTEM CONFIGURATION through the '$ConfigArg' argument "

    #----------------------------------------
    # INSERT ANY ADDITIONNAL SYSTEM CONFIG SCRIPT HERE 
    echo "Creating movit_backend.service..."
cat <<EOF >/etc/systemd/system/movit_backend.service
[Unit]
Description=-------- MOVIT+ BACKEND with node-red
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=pi
ExecStart=/usr/local/bin/node-red-pi -u $MovitPath/MOvIT-Detect-Backend --max-old-space-size=256

[Install]
WantedBy=multi-user.target
EOF

    echo "Creating movit_frontend.service..."
cat<<EOF >/etc/systemd/system/movit_frontend.service
[Unit]
Description=-------- MOVIT+ FRONTEND Express server
After=movit_backend.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
#The next line is the "yarn" command that runs on boot
#  To change its behavior please refer to the corresponding script in package.json
#  Package.json is located in the "WorkingDirectory".
ExecStart=/usr/bin/yarn start
WorkingDirectory=$MovitPath/MOvIT-Detect-Frontend/

[Install]
WantedBy=multi-user.target
EOF

    echo "Creating movit_acquisition.service..."
cat<<EOF >/etc/systemd/system/movit_acquisition.service
[Unit]
Description=-------- MOVIT+ acquisition software
After=network-online.target mosquitto.service
StartLimitIntervalSec=0

[Service]
# Set process niceness (priority) to maximum
#	(without being a near real-time process)
Nice=-20
Type=simple
# Ensures the process always restarts when it crashes
Restart=always
RestartSec=1
User=root
ExecStart=$MovitPath/MOvIT-Detect/Movit-Pi/Executables/movit-pi

[Install]
WantedBy=multi-user.target
EOF
    #----------------------------------------

    echo "Done updating system configuration"


#INITIALISE PROJECT
#via the argument $InitArg
elif [[ $1 == $InitArg || $2 == $InitArg ]]; then
    echo "### INITIALISING PROJECT though the '$InitArg' argument "

    #----------------------------------------
    echo "Using Movit folder location : $MovitPath"

    echo -e "###\n### Installing backend modules...\n###"
    cd $MovitPath/MOvIT-Detect-Backend && npm install

    echo "### Initialising database..."
    node $MovitPath/MOvIT-Detect-Backend/initDatabase.js
    
    echo -e "###\n### Installing frontend modules...\n###"
    cd $MovitPath/MOvIT-Detect-Frontend && yarn install --production --network-timeout 1000000
    #use of --production must be tested or optimized (remove unnecessary modules...)

    echo -e "###\n### Compiling bcm2835 library for the acquisition software...\n###"
    cd $MovitPath/MOvIT-Detect/bcm2835-1.58 && ./configure && make && make check && make install

    echo -e "###\n### Compiling acquisition software...\n###"
    cd $MovitPath/MOvIT-Detect/Movit-Pi && make -f MakefilePI all

    echo "### Enabling startup services..."
    systemctl enable movit_acquisition.service
    systemctl enable movit_frontend.service
    systemctl enable movit_backend.service

    #----------------------------------------

    echo "### Done initialising!"
    echo "System should be rebooted for services to start properly"


#REPOSITORY UPDATE THROUGH GITHUB
#Note : To run this command and successfully update the Git repo with $GitArg, the script must be run as such :
# curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
elif [[ $1 == $GitArg || $2 == $GitArg ]]; then
    echo "### Updating all Git repositories through the '$GitArg' argument"

    #----------------------------------------
    #Update function
    updateGithub () {
        echo "Update available, proceeding..."

        echo "### Stopping outdated services..."
        systemctl stop movit_acquisition.service
        systemctl stop movit_frontend.service
        systemctl stop movit_backend.service

        echo "### Updating repositories..."
        cd $MovitPath/ && git pull && git submodule update --init --recursive

        echo "### Starting updated services..."
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

