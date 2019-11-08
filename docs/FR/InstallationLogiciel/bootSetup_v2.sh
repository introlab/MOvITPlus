#!/bin/bash
#######################################################
####   MOVIT PLUS Project : First boot script      ####
####    - Hostname, AP interface config, AP name   ####
####    Author : Charles Maheu                     ####
#######################################################
# Redirect all outputs to a log file
exec 1>/home/pi/bootSetup.log 2>&1

# Exits if any command fails
set -e

#Log date
echo "Running initial setup script for a new Movit plus system"
echo "Current date : $(date)"

#######################################################
#Get MAC address
MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
echo "Detected MAC address : \"$MACAddr\" "

#AP interface
sed -i -e "s/b8:27:eb:xx:yy:zz/$MACAddr/g" /etc/udev/rules.d/70-persistent-net.rules

#Modify string to keep only last 3 bytes
MACname="$(echo ${MACAddr:9:8} | tr -d :)"

#Hostname part 1
sed -i -e "s/raspberrypi/Movit$MACname/g" /etc/hostname

#Hostname part 2
sed -i -e "s/raspberrypi/Movit$MACname/g" /etc/hosts

#AP name
sed -i -e "s/Movitxxyyzz/Movit$MACname/g" /etc/hostapd/hostapd.conf


#######################################################
echo "Setup completed, no errors"

#Delete self
rm $0
echo "Script deleted from boot folder"

#######################################################
exit 0
