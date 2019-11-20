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
set -e

#######################################################
#NETWORK SETUP
#######################################################
if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo "The network is up, proceeding..."
else
    read -p "Wifi configuration seems to be empty"
    read -p "Enter SSID: " SSID
    read -p "Enter password:" PSK
cat << EOF > wpa_supplicant.conf
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="Capsule" #Remplacer NOM_DU_RESEAU par le nom du réseau désiré
    psk="wolfpack" #Remplacer MOT_DE_PASSE par le mot de passe de celui-ci
    id_str="AP1"
}

EOF

    echo "wpa_supplicant.conf generated, launch this script on next boot to continue"
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

#TODO : timezone setup
#https://serverfault.com/questions/94991/setting-the-timezone-with-an-automated-script


#######################################################
#MOVIT BACKEND
#######################################################
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile #Permet au système de trouver le nouvel installation
nvm install 10.16.3 #Dernière version fonctionnelle testée
nvm alias default 10.16.3 #Mettre cette version par défaut

sudo apt-get install -y libkrb5-dev libzmq3-dev mosquitto-clients=1.6.4-0mosquitto1~buster1
#TODO : mosquitto password + config file
#sudo mosquitto_passwd -c /etc/mosquitto/passwd admin
#http://www.steves-internet-guide.com/mqtt-username-password-example/
sudo systemctl stop mosquitto
sudo sed -i '$ a #Password options' /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a password_file /etc/mosquitto/passwd' /etc/mosquitto/mosquitto.conf
sudo sed -i '$ a allow_anonymous false' /etc/mosquitto/mosquitto.conf
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



#######################################################
# SERVICES
#######################################################
cat <<EOF >/etc/systemd/system/movit_backend.service
[Unit]
Description=-------- MOVIT+ BACKEND with node-red
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=pi
ExecStart=/usr/local/bin/node-red-pi -u /home/pi/MOvITPlus/MOvIT-Detect-Backend --max-old-space-size=256

[Install]
WantedBy=multi-user.target
EOF

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
WorkingDirectory=/home/pi/MOvITPlus/MOvIT-Detect-Frontend/

[Install]
WantedBy=multi-user.target
EOF

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
ExecStart=/home/pi/MOvIT-Detect/Movit-Pi/Executables/movit-pi

[Install]
WantedBy=multi-user.target
EOF

cd /home/pi && sudo wget https://raw.githubusercontent.com/introlab/MOvITPlus/master/firstBootSetup.sh && chmod +x firstBootSetup.sh

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
echo "Updating '/etc/hostname' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hostname

echo "Updating '/etc/hosts' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hosts

echo "Updating '/etc/hostapd/hostapd.conf' with Movit-NOCONF..."
sed -i -e "s/raspberrypi/Movit-NOCONF/g;s/Movit-....../Movit-NOCONF/g;" /etc/hostapd/hostapd.conf

/home/pi/./firstBootSetup.sh --restore


exit 0