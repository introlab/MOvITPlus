# Configuration réseau
Il est possible d'utiliser la carte réseau du Raspberry Pi Zero W à la fois comme client et point d'accès. Les instructions originales sont tirées d'[ici](https://blog.thewalr.us/2017/09/26/raspberry-pi-zero-w-simultaneous-ap-and-managed-mode-wifi/).

# Ajout AP virtuel au démarrage du PI

La première étape est de créer une règle udev qui va ajouter notre ap virtuel, et le lier a l'interface par défaut du Raspberry Pi Zero W soit `wlan0`. Il faut connaitre l'adresse MAC de l'interface `wlan0` pour ce faire, il faut exécuté la commande `iw dev` la sortie devrait ressembler a la suivante:
```bash
pi@raspberrypi:~$ iw dev
phy#0
        Unnamed/non-netdev interface
                wdev 0x4
                addr ba:27:eb:07:28:1f
                type P2P-device
                txpower 31.00 dBm
        Interface wlan0
                ifindex 2
                wdev 0x1
                addr b8:27:eb:xx:xx:xx
                ssid <YOUR HOME SSID> 
                type managed
                channel 6 (2437 MHz), width: 20 MHz, center1: 2437 MHz
                txpower 31.00 dBm
```
L'adresse MAC de ce Raspberry Pi se trouve sous Inteface wlan0 > addr, dans notre situation l'adresse MAC de l’Interface wlan0 serait b8:27:eb:xx:xx:xx. Il faut aller inscrire cette adresse MAC dans une règle udev, afin que l'AP soit créé au démarrage. Il faudra modifier le fichier `/etc/udev/rules.d/70-persistent-net.rules` a l'aide de votre éditeur favori. Il faut inscrire dans le fichier les éléments suivant tout en prenant soin de remplacer l'adresse MAC par celle découverte précédemment:
```bash
SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="b8:27:eb:xx:xx:xx", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address b8:27:eb:xx:xx:xx"
```
La seconde adresse MAC est celle de notre AP virtuel, il peut être changé ou être le même que celui de `wlan0`, cela ne semble pas causer de problème ni créer de bénéfice. Pour que notre nouveau AP `ap0` soit visible, il faudra redémarrer le Raspberry Pi, toutefois il n'est pas nécessaire de faire ceci immédiatement.

# Installation de dnsmasq et hostapd
Ces deux programmes vont nous permettre de créer un point d'accès sur notre interface `ap0`, et de créer un serveur DHCP sur celui-ci pour pouvoir gérer les clients connectés sur le AP. Pour installer ces logiciels, il faut effectuer la commande suivante:
```bash
sudo apt-get install dnsmasq hostapd
```
Suite a cette commande, il faut quelques fichiers de configuration le premier fichier a modifié est `/etc/dnsmasq.conf` dans lequel il faut ajouter quelques lignes a la fin du fichier, voici ces lignes:
```bash
interface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h
```
Les adresses IP données par dnsmasq débuteront à `192.168.10.50` jusqu'à `192.168.10.150`. Il faut ensuite modifier le fichier `/etc/hostapd/hostapd.conf`, il faut écrire la configuration suivante: 
```bash
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=ap0
driver=nl80211
ssid=***NOM_DU_AP_ICI***
hw_mode=g
channel=11
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_passphrase=***MOT_DE_PASSE_ICI***
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
```

Il faut remplacer ssid (nom du réseau) actuellement `***NOM_DU_AP_ICI***` et le remplacer par un ssid plus pertinant le nom du projet suivi par les 3 derniers octets de l'adresse MAC du point d'accès par exemple `MOVIT+ XXXXXX`. Il faut également changer le mot de passe du point d'accès représenté ici par `***MOT_DE_PASSE_ICI***`. Ce mot de passe doit être au minimum de 8 caractères pour respecter la norme WPA. Le dernier fichier a modifier est `/etc/default/hostapd` dans lequel il faut modifier la clé `DAEMON_CONF` et la remplacer par:
```bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

# Modification fichier d'interface
Il faut modifier le fichier `/etc/wpa_supplicant/wpa_supplicant.conf` afin d'ajouter une configuration réseau quelconque, voici ce que devrait contenir le fichier:
```bash
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="SSID"
    psk="MOT_DE_PASSE"
    id_str="AP1"
}
```

Il faut évidemment remplacer `SSID` et `MOT_DE_PASSE` par des identifiants réseau valides. La clé `id_str` permet de définir une priorité réseau, si jamais il faut ajouter d'autre réseau, il faudrait incrémenter `AP1`. Il faut ensuite modifier `/etc/network/interfaces` afin d'activer nos interfaces réseau et leur assigné une adresse IP statique:
```bash
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
```
L'adresse IP de l'AP est définie ici soit `192.168.10.1`. Il est possible de changer cette adresse si nécessaire, tant que la configuration de dnsmasq est respectée, il ne devrait pas y avoir de problème. Il est important que l'interface `ap0` soit activée avant `wlan0`, autrement cela ne fonctionnera pas. 

# Démarrage de l'AP et partage de connexion
Il faut lancer l'AP manuellement au démarrage du Raspberry Pi, ce qui n'est pas pratique. C'est pourquoi un script qui s'éxécute à la toute fin de la sécance de démarrage du Raspberry Pi semble idéal. Nous allons également activer le partage d'internet entre les deux interfaces soit `wlan0` et `ap0` avec ce même script. Il faudra d'abord créer un fichier `start-ap-managed-wifi` à l'emplacement à `/home/pi`. Celui-ci doit contenir ces lignes:
```bash
#!/bin/bash
sudo ifdown --force wlan0 && sudo ifdown --force ap0 && sudo ifup ap0 && sudo ifup wlan0
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
sudo systemctl restart dnsmasq
```
Il faut rendre ce fichier exécutable a l'aide de `sudo chmod 755 /home/pi/start-ap-managed-wifi.sh`, puis créer une tâche de démarrage. IL faut ainsi créer un fichier de cette façon `sudo nano /etc/systemd/system/start-wifi.service` et y ajouter: 
```bash
[Unit]
Description=Starting AP and managed wifi with internet sharing
After=dnsmasq.service

[Service]
Type=forking
ExecStart= /home/pi/start-ap-managed-wifi.sh

[Install]
WantedBy=multi-user.target
```
Il faut ensuite exécuter `sudo systemctl daemon-reload` puis `sudo systemctl enable start-wifi.service`

Une fois tout ceci effectué, il faut redémarrer le Raspberry Pi. Au prochain démarrage l'AP devrait être visible et accessible.
