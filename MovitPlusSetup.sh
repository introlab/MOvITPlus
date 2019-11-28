#!/bin/bash
#######################################################
####   MOVIT PLUS Project :                        ####
####   Install script for Movit-detect             ####
####   Script geared towards the GENERATION OF A   ####
####   DISK IMAGE. All this setup will already be  ####
####   completed with preconfigured images.        ####
#######################################################
#                       /!\                           #
#   THIS SCRIPT HAS NOT BEEN FULLY TESTED             #
#   Use it as a guide and copy paste useful commands  #
#                       /!\                           #
#######################################################

#echo if any command fails
onexit(){ echo "----- Something went wrong, steps may have been skipped! ------"; }
trap onexit ERR



if [[ $1 == "--fresh-rasbian-image" ]]; then
    ##############################################################
    echo "#######################################################"
    echo "#NETWORK SETUP"
    echo "#######################################################"
    read -p "Proceed with step or skip (y/n) :" STEP_network
    if [[ $STEP_network == "y" ]]; then

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

    sudo apt-get update
    sudo apt-get install dnsmasq hostapd -y
    systemctl disable wpa_supplicant.service
    cat<<EOF >/etc/dnsmasq.conf
interface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h
EOF


    cat<<EOF >/etc/hostapd/hostapd.conf
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=ap0
driver=nl80211
ssid=Movit-NOCONF
hw_mode=g
channel=11
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_passphrase=movitplus
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
EOF


    cat<<EOF >>/etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF


    cat<<EOF >/etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
auto ap0
auto wlan0
iface lo inet loopback

allow-hotplug ap0
iface ap0 inet static
    address 192.168.10.1
    netmask 255.255.255.0
    hostapd /etc/hostapd/hostapd.conf

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface AP1 inet dhcp
EOF

    sed -i '/net.ipv4.ip_forward=1/s/^#//g' /etc/sysctl.conf
    sudo sysctl -p /etc/sysctl.conf

    sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE

    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    sudo apt-get -y install iptables-persistent

    else
    echo "Skipping step..."
    fi



    ##############################################################
    echo "#######################################################"
    echo "#MOVIT DETECT"
    echo "#######################################################"
    read -p "Proceed with step or skip (y/n) :" STEP_detect
    if [[ $STEP_detect == "y" ]]; then

    echo "Activating SPI and I2C"
    sed -i '/dtparam=i2c_arm=on/s/^#//g' /boot/config.txt
    sed -i '/dtparam=i2c_arm=on/s/^#//g' /boot/config.txt
    sudo apt-get install -y i2c-tools
    sudo echo "rtc-mcp7941x" | sudo tee --append /etc/modules
    sudo echo "dtoverlay=i2c-rtc,mcp7941x" | sudo tee --append /boot/config.txt 
    sed -i '7,9{s/^/#/}' /lib/udev/hwclock-set

    echo "Installing mosquitto, libraries, git and automake"
    wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
    sudo apt-key add mosquitto-repo.gpg.key
    cd /etc/apt/sources.list.d/
    sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list
    sudo apt-get install -y libkrb5-dev libzmq3-dev mosquitto-clients=1.6.4-0mosquitto1~buster1 libmosquitto1=1.6.4-0mosquitto1~buster1 mosquitto=1.6.4-0mosquitto1~buster1 libmosquitto-dev=1.6.4-0mosquitto1~buster1 libmosquittopp-dev=1.6.4-0mosquitto1~buster1 libmosquittopp1=1.6.4-0mosquitto1~buster1 --allow-downgrades
    sudo apt-get install -y git automake

    #Timezone setup, manually would be :
    #dpkg-reconfigure tzdata #-> requires user input
    #Automated :
    #https://serverfault.com/questions/94991/setting-the-timezone-with-an-automated-script
    echo "Setting timezone to America/Montreal"
    cp /usr/share/zoneinfo/America/Montreal /etc/localtime #What "dpkg-reconfigure" actually does anyways

    cd /home/pi
    git clone https://github.com/introlab/MOvIT-Detect.git
    echo -e "###\n### Compiling bcm2835 library for the acquisition software...\n###"
    cd MOvIT-Detect/bcm2835-1.60 && sudo -u pi ./configure && sudo -u pi make && make check && make install
    cd /home/pi && rm -r MOvIT-Detect/

    else
    echo "Skipping step..."
    fi



    ##############################################################
    echo "#######################################################"
    echo "#MOVIT BACKEND"
    echo "#######################################################"
    read -p "Proceed with step or skip (y/n) :" STEP_backend
    if [[ $STEP_backend == "y" ]]; then

    echo "Installing node and npm"
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
    source ~/.profile #Permet au système de trouver le nouvel installation
    nvm install 10.16.3 #Dernière version fonctionnelle testée
    nvm alias default 10.16.3 #Mettre cette version par défaut

    #Manual Mosquitto password + config file: 
    #sudo mosquitto_passwd -c /etc/mosquitto/passwd admin
    #http://www.steves-internet-guide.com/mqtt-username-password-example/

    echo "Configuring password for mosquitto mqtt"
    systemctl stop mosquitto
    cat<<EOF >>/etc/mosquitto/passwd
admin:movitplus
EOF
    mosquitto_passwd -U /etc/mosquitto/passwd

    cat<<EOF >/etc/mosquitto/mosquitto.conf
#Password options 
password_file /etc/mosquitto/passwd
allow_anonymous false
EOF
    systemctl start mosquitto

    echo "Installing mongod and node-red"
    apt-get install -y mongodb mongodb-server
    npm install -g node-red

    else
    echo "Skipping step..."
    fi


    ##############################################################
    echo "#######################################################"
    echo "#MOVIT FRONTEND"
    echo "#######################################################"
    read -p "Proceed with step or skip (y/n) :" STEP_frontend
    if [[ $STEP_frontend == "y" ]]; then

    echo "Installing yarn"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get install yarn -y

    cd /home/pi && wget https://raw.githubusercontent.com/introlab/MOvITPlus/master/firstBootSetup.sh && chmod +x /home/pi/firstBootSetup.sh

    else
    echo "Skipping step..."
    fi


    ##############################################################
    echo "#######################################################"
    echo "#OTHER SETUP"
    echo "#######################################################"
    read -p "Proceed with step or skip (y/n) :" STEP_other
    if [[ $STEP_other == "y" ]]; then

    echo "Creating movit_setup.service..."
    sudo cat <<EOF >/etc/systemd/system/movit_setup.service
[Unit]
Description=-------> MOVIT+ first boot setup script
After=network-online.target dnsmasq.service
Wants=network-online.target

[Service]
Type=forking
User=root
ExecStart=/home/pi/firstBootSetup.sh --fromService
TimeoutStartSec=25min 00s
ExecStartPost=reboot

[Install]
WantedBy=multi-user.target
EOF

    else
    echo "Skipping step..."
    fi


elif [[ $1 == "--prepare" ]]; then
    ##############################################################
    echo "#######################################################"
    echo "# RESETTING ALL CONFIG FOR IMAGE CREATION"
    echo "# Especially useful if setup script was triggered"
    echo "#######################################################"
    echo "Removing wpa setup"
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


    echo "Removing MOvITPlus"
    rm -r /home/pi/MOvITPlus



    echo "Removing movit_ services except movit_setup"
    rm /etc/systemd/system/movit_frontend.service
    rm /etc/systemd/system/movit_acquisition.service
    rm /etc/systemd/system/movit_backend.service

    systemctl daemon-reload
    /home/pi/./firstBootSetup.sh --restore
    
    echo "Removing self"
    rm /home/pi/MovitPlusSetup.sh


else
    echo " "
    echo "Warning : No arguments passed or invalid arguments!"
    echo "Use one of the following :"
    echo "   --prepare"
    echo "   --fresh-rasbian-image"
    echo " "
fi

echo "Exiting..."
exit 0
