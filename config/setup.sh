#!/bin/bash
sudo apt-get update
sudo apt-get install -y vim i2c-tools build-essential cmake mosquitto git \
	libmosquittopp-dev mosquitto-clients \
	mongodb mongodb-server libkrb5-dev libzmq3-dev

#stop mosquitto
sudo systemctl stop mosquitto

#mosquitto configuration
sudo echo "admin:movitplus\n" | sudo tee /etc/mosquitto/passwd
sudo mosquitto_passwd -U /etc/mosquitto/passwd
sudo cp network/mosquitto.conf /etc/mosquitto/mosquitto.conf
sudo systemctl start mosquitto

#nodejs
sudo wget -qO- https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs yarn


#network
# Not working at the moment, cannot have both stable client and master
# sudo cp network/90-persistent-net.rules /etc/udev/rules.d/

#dnsmasq hostapd
sudo apt-get install dnsmasq hostapd -y
sudo cp network/dnsmasq.conf /etc/dnsmasq.conf
sudo cp network/dnsmasq.service /lib/systemd/system/dnsmasq.service
sudo cp network/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp network/dhcpcd.conf /etc/dhcpcd.conf
sudo cp default/hostapd /etc/default/hostapd

#iptables
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
sudo apt-get install -y iptables-persistent
