#!/bin/bash
#####################################################################
####   MOVIT PLUS Project : First boot script                    ####
####    - Hostname and password, AP interface config, AP name    ####
####    Author : Charles Maheu                                   ####
#####################################################################

exec 1>/home/pi/bootSetup.log 2>&1
#Create new log file with the date
echo "Running initial setup script for a new Movit plus system"
echo "Current date : $(date)"

#Get MAC address
MACAddr="$(ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')"
if [ $? -eq 0 ]; then
    echo "Detected MAC address : \"$MACAddr\" "
else
    echo "Failed to find MAC address. Exiting..."
    exit 1
fi

#AP interface
FilePath="/home/pi/test/70-persistent-net.rules" #"/etc/udev/rules.d/70-persistent-net.rules"
sed -i -e "s/b8:27:eb:xx:yy:zz/$MACAddr/g" $FilePath
if [ $? -eq 0 ]; then
    echo "Successfully changed MAC address in AP interface at $FilePath"
else
    echo "Failed to change MAC address in AP interface at $FilePath. Exiting..."
    exit 1
fi

MACname="$(echo ${MACAddr:9:8} | tr -d :)"

#Hostname part 1
FilePath="/home/pi/test/hostname" #"/etc/hostname"
sed -i -e "s/raspberrypi/Movit$MACname/g" $FilePath
if [ $? -eq 0 ]; then
    echo "Successfully changed Hostname in $FilePath"
else
    echo "Failed to change Hostname in $FilePath. Exiting..."
    exit 1
fi

#Hostname part 2
FilePath="/home/pi/test/hosts" #"/etc/hosts"
sed -i -e "s/raspberrypi/Movit$MACname/g" $FilePath
if [ $? -eq 0 ]; then
    echo "Successfully changed Hostname in $FilePath"
else
    echo "Failed to change Hostname in $FilePath. Exiting..."
    exit 1
fi

#AP name
FilePath="/home/pi/test/hostapd.conf" #"/etc/hostapd/hostapd.conf"
sed -i -e "s/Movitxxyyzz/Movit$MACname/g" $FilePath
if [ $? -eq 0 ]; then
    echo "Successfully changed AP name in $FilePath"
else
    echo "Failed to change AP name in $FilePath. Exiting..."
    exit 1
fi

#Delete self
#rm $0

return
exit 0
