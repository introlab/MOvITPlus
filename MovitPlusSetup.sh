#!/bin/bash
#######################################################
####   MOVIT PLUS Project :                        ####
####   Install script for Movit-detect             ####
####   Script geared towards the GENERATION OF A   ####
####   DISK IMAGE. All this setup will already be  ####
####   completed with preconfigured images.        ####
#######################################################
#                       /!\                           #
#   COPYING ONLY NECESSARY PARTS IS HIGLY SUGGESTED   #
#                       /!\                           #
#######################################################

#Exits if any command fails
set -e

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
sudo apt-get install -y git

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



exit 0