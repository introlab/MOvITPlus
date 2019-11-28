#!/bin/bash
#######################################################
####  MOVIT PLUS Project :
####   This script is aimed at facilitating the creation of an image after inserting a fully configured source SD card
####   Script should be executed on a linux computer with the SD card inserted as the /dev/sde device
####   Manually change the script to respect this path for the SD card (check path with sudo fdisk -l)
####   Execute as su
####   VERIFY THE MENTIONNED DRIVE PATH IS CORRECT BEFORE USING
####  Source : https://medium.com/platformer-blog/creating-a-custom-raspbian-os-image-for-production-3fcb43ff3630
#######################################################
if ! [ $(id -u) = 0 ]; then
   echo "The script needs to be run as root." >&2; exit 1; fi

#REQUIRED STUFF :
#PiShrink Script
# wget  https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh && chmod +x pishrink.sh && sudo mv pishrink.sh /usr/local/bin && echo "PiShrink script installed in /usr/local/bin" 

#Balena Etcher CLI :
#NOTE : Balena Etcher with the interface can also be used easily.
# https://github.com/balena-io/balena-cli/blob/master/INSTALL.md#executable-installer
# If the downloaded and unzipped folder is in download ($HOME/Downloads/balena-cli) then :
export PATH=$PATH:$HOME/Downloads/balena-cli #Allows script environment to understand where Balena Etcher CLI is

echo "The fully configured source SD card should be plugged in to continue"
read -p "When ready, input version number : " NUM
dd status=progress if=/dev/sde of=$HOME/MovitImages/Movit-unshrunk$NUM.img
echo -e "\nSource SD card can now be removed. Shrinking image..."
pishrink.sh -z $HOME/MovitImages/Movit-unshrunk$NUM.img $HOME/MovitImages/Movit_V$NUM.img && rm $HOME/MovitImages/Movit-unshrunk$NUM.img

echo ""
read -p "Press enter when target SD card is inserted"
echo "Flashing new image on inserted SD card..."
balena local flash $HOME/MovitImages/Movit_V$NUM.img.gz -y --drive /dev/sde

echo -e "\nConfiguring wpa_supplicant for the first boot with the flashed SD card"
read -p "     Enter SSID: " SSID
read -p " Enter password: " PSK

read -p "Remove and reinsert the card and press enter"
cd /media/charles/boot/ && cat << EOF > wpa_supplicant.conf
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$SSID" #Remplacer NOM_DU_RESEAU par le nom du réseau désiré
    psk="$PSK" #Remplacer MOT_DE_PASSE par le mot de passe de celui-ci
    id_str="AP1"
}
EOF && cat wpa_supplicant.conf
exit 0