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
onexit(){ echo "Something went wrong, exiting..."; exit 1; }
trap onexit ERR

#Constants
HomePath="/home/pi"
MovitPath="$HomePath/MOvITPlus"

#Functions
restore () {
    systemctl enable movit_setup.service
    echo "Script will run on next boot..."
}

remove () {
    systemctl disable movit_setup.service
    echo "Script will no longer run on next boot..."
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

    echo -e "\n\n########################################################"
    echo "Running initial setup script for a new Movit plus system"
    if [[ $1 == "--fromService" ]]; then echo "Lauched from systemd service"; failmesg="reboot the system" 
    else echo "Lauched with the following arguments : $1 $2"; failmesg="run the script again"; fi
    echo "Current date : $(date)"
    echo "########################################################"

    #Verify connectivity (will not run if device fails to ping through DNS server)
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "### The network is up, proceeding..."

        MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')" #Get MAC address
        MACname="$(echo ${MACAddr:9:8} | tr -d :)" #Modify string to keep only last 3 bytes and delete all ":"
        MACname=${MACname^^}
        echo "### Detected MAC address : '$MACAddr' "

        echo "### Creating '/etc/udev/rules.d/70-persistent-net.rules'..."
        #Old replacement method :
        #sed -i -e "s/b8:27:eb:..:..:../$MACAddr/g" /etc/udev/rules.d/70-persistent-net.rules
cat <<EOF > /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="$MACAddr", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address $MACAddr"

EOF
        echo "### Updating '/etc/hostname' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hostname

        echo "### Updating '/etc/hosts' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hosts

        echo "### Updating '/etc/hostapd/hostapd.conf' with Movit-$MACname..."
        sed -i -e "s/raspberrypi/Movit-$MACname/g;s/Movit-....../Movit-$MACname/g;" /etc/hostapd/hostapd.conf

        echo "### Networks should be fully operationnal on next reboot"

        echo -e "### Using '$(date)' and updating hardware clock...\n###"
        #Assuming the date and time is correctly set (timezones)
        hwclock -w --verbose
        echo "### Done setting RTC time"


        #INSTALLS GIT REPOSITORY AND INITIALISES IT WITH `updateProject.sh`
        #Only if "--nogit" argument is not passed
        if [[ $1 != --nogit && $2 != --nogit ]]; then
            #export GIT_SSL_NO_VERIFY=1 #If device date is wrong, this command will make git work anyways
            

            if [ -d "$MovitPath/" ]; then
            #--If a MOvITPlus installation is detected : 
            echo -e "###\n### 'MOvITPlus/' folder detected"
            echo -e "### Skipping installation of GitHub directories ###"
            echo -e "### INFO : Delete folder and relaunch this script to reinstall directories...\n###"
            #--
            echo "### Making updateProject.sh executable in case it wasn't..."
            chmod +x $MovitPath/updateProject.sh
            #--Update installation...
            echo -e "###\n### Updating project :"
            echo -e "### Executing online version of 'updateProject.sh' with '--git-update'...\n###"
            curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
            echo "Script successful, see updateProject.log"


            else
            #--If no MOvITPlus installation :
            echo -e "###\n### 'MOvITPlus/' folder not detected"
            echo -e "### Installing necessary GitHub directories...\n###";
            cd $HomePath/ && sudo -u pi git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules
            #--
            echo "### Making updateProject.sh executable in case it wasn't..."
            chmod +x $MovitPath/updateProject.sh
            fi


            echo -e "### Updating system configuration :"
            echo -e "###\n### Executing 'updateProject.sh' with '--sys-config'...\n###"
            $MovitPath/./updateProject.sh --sys-config
            echo "### Script successful, see updateProject.log..."


            #This next part of the script is long to execute. Should be launched manually if needed
            #echo -e "###\n### Executing 'updateProject.sh' with '--init-project'...\n###"
            #$MovitPath/./updateProject.sh --init-project
            #echo "Script successful, see updateProject.log"

        else
            echo "### Skipping git installation because of '--nogit' argument"
        fi
        remove
        echo "### Rebooting to finish network setup..."
        echo "### If the system doesn't reboot, please do so manually."
        #######################################################
    else
        echo "### The network is down, cannot run first boot setup"
        echo "### Please fix internet connection and $failmesg."
        exit 1
    fi
    
fi

echo -e "### Exiting...\n########################################################"
exit 0