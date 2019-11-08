#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Hostname, AP interface config, AP name   ####
####    Author : Charles Maheu                     ####
#######################################################

# Exits if any command fails
set -e

#RESTORE SCRIPT FOR EXECUTION ON NEXT BOOT
#via the argument --restore
if [ $1 == "--restore" ]; then
    sed -i "$ i /bin/bash /home/pi/MOvITPlus/firstBootSetup.sh" /etc/rc.local
    echo "Added script execution line to /etc/rc.local"
    echo "Script will run on next boot..."
else

#ACTUAL SCRIPT
# Redirect all outputs to a log file
exec 1>/home/pi/MOvITPlus/firstBootSetup.log 2>&1

#Log date
echo "Running initial setup script for a new Movit plus system"
echo "Current date : $(date)"

#######################################################
#Get MAC address
MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
echo "Detected MAC address : \"$MACAddr\" "
#Modify string to keep only last 3 bytes
MACname="$(echo ${MACAddr:9:8} | tr -d :)"


#AP interface
sed -i -e "s/b8:27:eb:xx:yy:zz/$MACAddr/g" /etc/udev/rules.d/70-persistent-net.rules

#Hostname part 1
sed -i -e "s/raspberrypi/Movit$MACname/g" /etc/hostname

#Hostname part 2
sed -i -e "s/raspberrypi/Movit$MACname/g" /etc/hosts

#AP name
sed -i -e "s/Movitxxyyzz/Movit$MACname/g" /etc/hostapd/hostapd.conf


#######################################################
echo "Setup completed, no errors"

#Delete execution line from /etc/rc.local
sed -i '\/bin\/bash \/home\/pi\/MOvITPlus\/firstBootSetup.sh/d' /etc/rc.local
echo "Removed script execution line from /etc/rc.local"

#######################################################
fi
exit 0

