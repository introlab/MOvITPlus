#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Set Hostname, AP interface, AP name      ####
####    - Set RTC time                             ####
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
#Functions

restore () {
    if grep -Fxq "/bin/bash $HomePath/firstBootSetup.sh --fromRClocal" /etc/rc.local; then
            echo "Script execution line is already in /etc/rc.local"
    else
        #Add execution line from /etc/rc.local
        sed -i "$ i sleep 10s" /etc/rc.local #To ensure network availability
        sed -i "$ i /bin/bash $HomePath/firstBootSetup.sh --fromRClocal" /etc/rc.local
        echo "Added script execution line to /etc/rc.local"
        echo "Script will run on next boot..."
    fi
}

remove () {
    if grep -Fxq "/bin/bash $HomePath/firstBootSetup.sh --fromRClocal" /etc/rc.local; then
        #Delete execution line from /etc/rc.local
        sed -i '/sleep 10s/d' /etc/rc.local
        sed -i '/\/bin\/bash \/home\/pi\/firstBootSetup.sh --fromRClocal/d' /etc/rc.local
        echo "Removed script execution line from /etc/rc.local"
    else
        echo "No script execution line to remove in /etc/rc.local"
    fi
}

#RESTORE OR REMOVE SCRIPT FOR EXECUTION ON NEXT BOOT
#via the argument --restore and --remove
if [[ $1 == "--restore" ]]; then
    restore
elif [[ $1 == "--remove" ]]; then
    remove
else


    #######################################################
    #ACTUAL SCRIPT
    if [[ $1 != --console-log && $2 != --console-log ]]; then
        # Redirect all outputs to a log file
        exec 1>>$HomePath/firstBootSetup.log 2>&1
    fi

    echo ""
    echo ""
    echo "########################################################"
    echo "Running initial setup script for a new Movit plus system"
    if [[ $1 == "--fromRClocal" ]]; then echo "Lauched from rc.local"
    else [[ $1 == "" ]] || echo "Lauched with the following arguments : $1 $2";fi
    echo "Current date : $(date)"
    echo "########################################################"

    #Verify connectivity (will not run if device fails to ping through DNS server)
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "The network is up, proceeding..."

        MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')" #Get MAC address
        MACname="$(echo ${MACAddr:9:8} | tr -d :)" #Modify string to keep only last 3 bytes and delete all ":"
        MACname=${MACname^^}
        echo "Detected MAC address : '$MACAddr' "

        echo "Creating '/etc/udev/rules.d/70-persistent-net.rules'..."
        #Old replacement method :
        #sed -i -e "s/b8:27:eb:..:..:../$MACAddr/g" /etc/udev/rules.d/70-persistent-net.rules
        cat <<EOF > /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="$MACAddr", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address $MACAddr"

EOF
        echo "Updating '/etc/hostname' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hostname

        echo "Updating '/etc/hosts' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hosts

        echo "Updating '/etc/hostapd/hostapd.conf' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hostapd/hostapd.conf

        echo "Networks should be fully operationnal"

        echo "Using '$(date)' and updating hardware clock..."
        #Assuming the date and time is correctly set (timezones)
        sudo hwclock -w --verbose
        echo "Done setting RTC time"


        #INSTALLS GIT REPOSITORY AND INITIALISES IT WITH `updateProject.sh`
        #Only if "--nogit" argument is not passed
        if [[ $1 != --nogit && $2 != --nogit ]]; then
            echo ""
            echo "### Installing necessary GitHub directories..."
            cd $HomePath/ && git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules

            echo ""
            echo "### Restoring proper group and ownership of the Git repository folders..."
            chown -R pi:pi $MovitPath
            echo "### Making updateProject.sh executable in case it wasn't..."
            chmod +x $MovitPath/updateProject.sh

            echo ""
            echo "### Executing 'updateProject.sh' with '--sys-config'..."
            $MovitPath/./updateProject.sh --sys-config
            echo "Script successful, see updateProject.log..."

            echo ""
            echo "### Executing 'updateProject.sh' with '--init-project'..."
            $MovitPath/./updateProject.sh --init-project
            echo "Script successful, see updateProject.log"

        else
            echo "### Skipping git installation because of '--nogit' argument"
        fi

        #######################################################
    else
        echo "The network is down, cannot run first boot setup"
        echo "Please fix internet connection and try again"
    fi
    remove
fi


echo "Exiting..."
exit 0

