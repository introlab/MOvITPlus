#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Set Hostname, AP interface, AP name      ####
####    - Initial installation                     ####
####   Author : Charles Maheu                      ####
####                                               ####
####   THIS SCRIPT SHOULD BE IN /home/pi/          ####
####                                               ####
#######################################################

#Exits if any command fails
set -e
#Constants
HomePath="/home/pi"
MovitPath="$HomePath/MOvITPlus"

#RESTORE OR REMOVE SCRIPT FOR EXECUTION ON NEXT BOOT
#via the argument --restore and --remove
if [ $1 == "--restore" ]; then
    if grep -Fxq "/bin/bash $HomePath/firstBootSetup.sh" /etc/rc.local; then
        echo "Script execution line is already in /etc/rc.local"
    else
    #Add execution line from /etc/rc.local
        sed -i "$ i /bin/bash $HomePath/firstBootSetup.sh" /etc/rc.local
        echo "Added script execution line to /etc/rc.local"
        echo "Script will run on next boot..."
    fi
elif [ $1 == "--remove" ]; then
    if grep -Fxq "/bin/bash $HomePath/firstBootSetup.sh" /etc/rc.local; then
    #Delete execution line from /etc/rc.local
        sed -i '\/bin\/bash \/home\/pi\/firstBootSetup.sh/d' /etc/rc.local
        echo "Removed script execution line from /etc/rc.local"

    else
        echo "No script execution line to remove in /etc/rc.local"
    fi
else

    #ACTUAL SCRIPT
    # Redirect all outputs to a log file
    exec 1>>$HomePath/firstBootSetup.log 2>&1

    #Log date
    echo "Running initial setup script for a new Movit plus system"
    echo "Current date : $(date)"

    #######################################################
    #Verify connectivity (will not run if device fails to ping through DNS server)
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "The network is up, proceeding..."
        
        #Get MAC address
        MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
        echo "Detected MAC address : \"$MACAddr\" "
        #Modify string to keep only last 3 bytes and delete all ":"
        MACname="$(echo ${MACAddr:9:8} | tr -d :)"


        #AP interface
        sed -i -e "s/b8:27:eb:..:..:../$MACAddr/g" /etc/udev/rules.d/70-persistent-net.rules

        #Hostname part 1
        sed -i -e "s/raspberrypi/Movit$MACname/g;s/Movit....../Movit$MACname/g;" /etc/hostname
        #Old method #sed -i -e "s/raspberrypi/Movit$MACname/g" /etc/hostname

        #Hostname part 2
        sed -i -e "s/raspberrypi/Movit$MACname/g;s/Movit....../Movit$MACname/g;" /etc/hosts

        #AP name
        sed -i -e "s/raspberrypi/Movit$MACname/g;s/Movit....../Movit$MACname/g;" /etc/hostapd/hostapd.conf

        #######################################################
        echo "Setup completed, no errors"
        echo "At this point, after a reboot, networks should be fully functionnal."

        #Delete execution line from /etc/rc.local
        sed -i '\/bin\/bash \/home\/pi\/firstBootSetup.sh/d' /etc/rc.local
        echo "Removed script execution line from /etc/rc.local"

        #
        #INSTALLS GIT REPOSITORY AND INITIALISES IT WITH `updateProject.sh`
        #Only if "--mac" argument is passed
        if [[ $1 != --nogit && $2 != --nogit ]]; then
            #Installing git repositories
            echo "Installing necessary GitHub directories"
            cd $HomePath/
            git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules

            #Executing update script
            $MovitPath./updateProject.sh --rtc-time
            $MovitPath./updateProject.sh --sys-config
            $MovitPath./updateProject.sh --init-project
        else
            echo "Skipping git installation because of '--nogit' argument"
        fi

        #######################################################
        reboot now
    else
        echo "The network is down, cannot run first boot setup"
        echo "Please fix internet connection and try again"
    fi
fi

echo "Exiting..."
exit 0

