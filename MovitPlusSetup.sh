#!/bin/bash
#######################################################
####   MOVIT PLUS Project :                        ####
####   Install script for Movit-detect             ####
####   Script geared towards the GENERATION OF A   ####
####   DISK IMAGE. All this setup will already be  ####
####   completed with preconfigured images.        ####
#######################################################
#                       /!\                           #
#   THIS SCRIPT SHOULD BE RUN WITH A CURL COMMAND     #
#                       /!\                           #
#######################################################
#TODO : Comments and explainations (reference to docs?)

#Exits if any command fails
#set -e

#######################################################
#NETWORK SETUP
#######################################################
if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "The network is up, proceeding..."
else

    echo "Wifi may not be properly configured"
    read -p "Enter SSID: " SSID
    read -p "Enter password:" PSK
    echo "SSID : $SSID, PSK : $PSK"
cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$SSID" #Remplacer NOM_DU_RESEAU par le nom du réseau désiré
    psk="$PSK" #Remplacer MOT_DE_PASSE par le mot de passe de celui-ci
    id_str="AP1"
}

EOF
    echo "wpa_supplicant.conf generated, launch this script again on next boot to continue"
    echo "Rebooting in 5 seconds"
    sleep 5s
    reboot
    exit 0
fi


#######################################################
#MOVIT DETECT
#######################################################
sed -i '/dtparam=i2c_arm=on/s/^#//g' /boot/config.txt
sed -i '/dtparam=i2c_arm=on/s/^#//g' /boot/config.txt
sudo apt-get install -y i2c-tools
sudo echo "rtc-mcp7941x" | sudo tee --append /etc/modules
sudo echo "dtoverlay=i2c-rtc,mcp7941x" | sudo tee --append /boot/config.txt 
sed -i '7,9{s/^/#/}' /lib/udev/hwclock-set

wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
sudo apt-key add mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list
sudo apt-get update
sudo apt-get install -y libkrb5-dev libzmq3-dev mosquitto-clients=1.6.4-0mosquitto1~buster1 libmosquitto1=1.6.4-0mosquitto1~buster1 mosquitto=1.6.4-0mosquitto1~buster1 libmosquitto-dev=1.6.4-0mosquitto1~buster1 libmosquittopp-dev=1.6.4-0mosquitto1~buster1 libmosquittopp1=1.6.4-0mosquitto1~buster1 --allow-downgrades
sudo apt-get install -y git automake

#Timezone setup, manually would be :
#dpkg-reconfigure tzdata #-> requires user input
#https://serverfault.com/questions/94991/setting-the-timezone-with-an-automated-script
cp /usr/share/zoneinfo/America/Montreal /etc/localtime #What the above command actually does in the end


#######################################################
#MOVIT BACKEND
#######################################################
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile #Permet au système de trouver le nouvel installation
nvm install 10.16.3 #Dernière version fonctionnelle testée
nvm alias default 10.16.3 #Mettre cette version par défaut

#TODO : mosquitto password + config file
#sudo mosquitto_passwd -c /etc/mosquitto/passwd admin
#http://www.steves-internet-guide.com/mqtt-username-password-example/
sudo systemctl stop mosquitto
cat<<EOF >>/etc/mosquitto/mosquitto.conf
#Password options 
password_file /etc/mosquitto/passwd
allow_anonymous false
EOF
sudo systemctl start mosquitto

sudo apt-get install -y mongodb mongodb-server
npm install -g node-red


#######################################################
#MOVIT BACKEND
#######################################################
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y #au besoin
sudo apt-get install yarn -y

cd /home/pi && wget https://raw.githubusercontent.com/introlab/MOvITPlus/master/firstBootSetup.sh && chmod +x /home/pi/firstBootSetup.sh

#######################################################
# RESET ALL CONFIG FOR IMAGE CREATION
#######################################################
cat<<EOF >/etc/wpa_supplicant/wpa_supplicant.conf
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="NOM_DU_RESEAU" #Remplacer NOM_DU_RESEAU par le nom du réseau désiré
    psk="MOT_DE_PASSE" #Remplacer MOT_DE_PASSE par le mot de passe de celui-ci
    id_str="AP1"
}
EOF
echo "Deleting '/etc/udev/rules.d/70-persistent-net.rules'..."
rm /etc/udev/rules.d/70-persistent-net.rules

echo "Updating '/etc/hostname' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hostname

echo "Updating '/etc/hosts' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hosts

echo "Updating '/etc/hostapd/hostapd.conf' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hostapd/hostapd.conf

/home/pi/./firstBootSetup.sh --restore

rm -r /home/pi/MOvITPlus
rm /home/pi/MovitPlusSetup.sh
rm /etc/systemd/system/movit_frontend.service
rm /etc/systemd/system/movit_acquisition.service
rm /etc/systemd/system/movit_backend.service
systemctl disable wpa_supplicant.service


exit 0