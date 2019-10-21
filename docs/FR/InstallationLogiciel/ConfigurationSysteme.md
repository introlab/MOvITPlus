# Configuration du système

### Table des matières :

- **[1. Configuration réseau](#1.-configuration-réseau "Wi-fi, ssh, access point et nom de domaine")** 
- **[2. Configuration du démarrage](#2.-configuration-du-démarrage "Scripts de lancement, services avec systemd et optimisations")**
- **[3. Installation de MOvIT +](#3.-installation-de-movit-+ "Installation du projet")**
- **[4. Mises à jour du système](#4.-mises-à-jour-du-système "Processus de mise à jour")**
___

<br>
<br>

# 1. Configuration réseau
Il est possible d'utiliser la carte réseau du Raspberry Pi Zero W à la fois comme client et point d'accès. Ce point d'accès peut ainsi fournir à la fois une connection internet et une connection à l'interface web du projet. Les instructions sont tirées principalement d'[ici](https://community.ptc.com/t5/IoT-Tech-Tips/Using-the-Raspberry-Pi-as-a-WIFI-hotspot/td-p/535058).

Fonctionnement en bref :
- **ifup :** Met en fonction les connections sans fil configurées. Deux instances de ifup sont créées; _ifup@wlan0_, pour la connection au wi-fi, et _ifup@ap0_, pour la gestion du point d'accès. Ces instances font appels à **wpa_supplicant** / **_dhclient_** et **hostapd** respectivement.
  >Il est utilisé en conjonction avec **_ifdown_**, qui ferme ces connections au besoin.
  - **wpa_supplicant / dhclient :** Gère la connection à d'autres points d'accès wi-fi
  - **hostapd :** Permet la création d'un point d'accès à même le RaspberryPi
- **dnsmasq :** Fournit les services DHCP, soit l'assignation d'addresse IP aux appareils connectés à un réseau (AP), et DNS, soit l'utilisation de l'addresse [movit.plus](http://movit.plus) à la place de [192.168.10.1](http://192.168.10.1).
- **Avahi :** Permet la communication et l'échange de services sur les réseaux configurés via le protocole mDNS/DNS-SD. Utile notamment pour l'accès à l'addresse _hostname-de-l'appareil_.local pour ouvrir une session en **ssh**.
  - **ssh :** Permet la connection à distance à la console du RaspberryPi, pour fonctionner sans l'aide d'un écran/clavier branché au RaspberryPi (headless mode).

### 1.1. Connection à un réseau wi-fi
> Il est aussi possible d'utiliser l'utilitaire `raspi-config` pour réaliser l'équivalent de ces étapes.

La première chose à faire une fois le RaspberryPi ouvert pour la première fois est de modifier le fichier `/etc/wpa_supplicant/wpa_supplicant.conf` afin d'ajouter une configuration réseau quelconque, voici ce que devrait contenir le fichier:
```bash
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="SSID"
    psk="MOT_DE_PASSE"
    id_str="AP1"
}
```

Il faut évidemment remplacer `SSID` et `MOT_DE_PASSE` par des identifiants réseau valides. La clé `id_str` permet de définir une priorité réseau, si jamais il faut ajouter d'autres réseaux, il faudrait incrémenter `AP1`.

> **Utilisation headless :** le fichier `wpa_supplicant.conf` dûment remplit peut être placé dans la partition boot d'une carte SD nouvellement flashé. Le système déplacera alors ce fichier au bon endroit et l'utilisera afin de permettre une connection au wifi voulu dès le premier démarrage.

### 1.2. Activation du SSH
Secure Shell (SSH) peux être activé à l'aide du menu _raspi-config_.
> **Utilisation headless :** Il peut également être activé en plaçant un fichier sans extension nommé ssh dans la partition de boot de l'image fraichement flashée.

### 1.3. Ajout de l'_access point_ comme interface
Il faut créer une règle udev qui va ajouter le point d'accès virtuel, et le lier a l'interface par défaut du RaspberryPi Zero soit `wlan0`. Il faut connaitre l'adresse MAC de l'interface `wlan0`. Pour se faire, la commande suivante devrait retourner l'addresse directement :
```bash
ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
```
>Sinon, il faut exécuter la commande `iw dev`. La sortie devrait ressembler a la suivante:
>```bash
>pi@raspberrypi:~$ iw dev
>phy#0
>        Unnamed/non-netdev interface
>                wdev 0x4
>                addr ba:27:eb:07:28:1f
>                type P2P-device
>                txpower 31.00 dBm
>        Interface wlan0
>                ifindex 2
>                wdev 0x1
>                addr b8:27:eb:xx:xx:xx
>                ssid <YOUR HOME SSID> 
>                type managed
>                channel 6 (2437 MHz), width: 20 MHz, center1: 2437 MHz
>                txpower 31.00 dBm
>```
>L'adresse MAC de ce Raspberry Pi se trouve sous Inteface wlan0 > addr, dans notre situation l'adresse MAC de l’Interface wlan0 serait b8:27:eb:xx:xx:xx.

Il faut aller inscrire cette adresse MAC dans une règle udev, afin que l'_access point_ en tant qu'interface valide. Il faudra modifier ou créer le fichier `/etc/udev/rules.d/70-persistent-net.rules` à l'aide de votre éditeur favori. Il faut inscrire dans le fichier les éléments suivants tout en prenant soin de remplacer l'adresse MAC par celle découverte précédemment:
```bash
SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="b8:27:eb:xx:xx:xx", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address b8:27:eb:xx:xx:xx"
```
La seconde adresse MAC est celle de notre AP virtuel, il peut être changé ou être le même que celui de `wlan0`, cela ne semble pas causer de problème.

### 1.4. Configuration de DNSmasq et Hostapd
Ces deux programmes vont nous permettre de créer un point d'accès sur notre interface `ap0`, et de créer un serveur DHCP sur celui-ci pour pouvoir gérer les clients connectés sur le AP. Pour installer ces logiciels, il faut effectuer la commande suivante:
```bash
sudo apt-get install dnsmasq hostapd
```
##### dnsmasq.conf :
Suite a cette commande, il faut mettre en place quelques fichiers de configuration. Le premier fichier à modifier est `/etc/dnsmasq.conf` dans lequel il faut ajouter quelques lignes à la fin, voici ces lignes:
```bash
interface=lo,ap0
no-dhcp-interface=lo,wlan0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h
```

Les adresses IP données par dnsmasq débuteront ainsi à `192.168.10.50` jusqu'à `192.168.10.150`.
##### hostapd :
Il faut ensuite modifier le fichier `/etc/hostapd/hostapd.conf` pour y écrire la configuration suivante : 
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

Il faut remplacer ssid (nom du réseau) actuellement `***NOM_DU_AP_ICI***` et le remplacer par un ssid plus pertinant le nom du projet suivi par les 3 derniers octets de l'adresse MAC du point d'accès par exemple `MOVIT+ XXXXXX`. Il faut également changer le mot de passe du point d'accès représenté ici par `***MOT_DE_PASSE_ICI***`. Ce mot de passe doit être au minimum de 8 caractères pour respecter la norme WPA.

Ensuite, `/etc/default/hostapd` doit être modifié de façon à changer la clé `DAEMON_CONF` et la remplacer par:
```bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```
### 1.5. Configuration des interfaces 
Il faut ensuite modifier `/etc/network/interfaces` afin d'activer les interfaces réseau et leur assigner une adresse IP statique:
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

L'adresse IP de l'AP est ainsi définie ici, soit `192.168.10.1`. Il est possible de changer cette adresse si nécessaire, tant que la configuration de dnsmasq est respectée, il ne devrait pas y avoir de problème. Il est important que l'interface `ap0` soit activée avant `wlan0`, autrement cela ne fonctionnera pas.

### 1.6. Configuration du nom de domaine
DNSmasq lit le fichier `/etc/hosts` afin d'associer certaines addresses à des noms de domaines. Cette fonction est utilisée pour rediriger le traffic vers le la bonne addresse si une tentative est faite pour se connecter aux noms de domaines spécifiés. À ce fichier, il faut ajouter ces lignes à la fin :
```bash
#Allows access to the frontend and the backend with an easier to remember address:
192.168.10.1	movit	movit.plus
``` 


### 1.7. Partage de connexion
Un fichier de configuration doit être modifié pour permettre d'activer le partage de connection internet entre les deux interfaces, soit wlan0 et ap0. Ainsi, dans `/etc/sysctl.conf`, il faut décommenter la ligne `net.ipv4.ip_forward=1`. Il faut ensuite exécuter la commande `sudo sysctl -p /etc/sysctl.conf` pour mettre en effet ces changements.

Ensuite, pour permettre la transcription des addresses IP pour compléter la connection internet, il faut exécuter la commande :
```bash
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
```
Pour rendre ces règles persistentes, _iptables-persistent_ est la meilleure solution. Pour l'installer :
```bash
sudo apt-get install iptables-persistent
```
Lorsque demandé, il faut appuyer sur _oui_ pour sauvegarder les règles actuelles.


### 1.8. Démarrage de l'AP et 
DNSmasq doit démarrer au bon moment pour fonctionner correctement. Pour assurer cela, il faut modifier une ligne dans son fichier _.service_ de façon à ce qu'il démarre uniquement lorsque le démarrage des réseaux est complété. Dans le fichier `/lib/systemd/system/dnsmasq.service`, il faut ajouter "network-online.target" à ces deux lignes sous [Unit] :
```bash
Wants=nss-lookup.target network-online.target
After=network.target network-online.target
```
Si DNSmasq n'est pas activé au démarrage, cette commande permettra de le faire : `sudo systemctl enable dnsmasq.service`. Cependant, il devrait déjà l'être.

Une fois que toutes ces étapes sont complétées, il est possible de redémarrer le Raspberry Pi. L'AP deviendra alors visible et accessible.
___

<br>
<br>

# 2. Configuration du démarrage
Le démarrage des différents services créés pour le projet est l'élément crucial permettant au RasbperryPi Zero d'exécuter le code conçu dès le branchement de l'appareil.
### 2.1. Services avec systemd
Puisque l'image utilisé est Raspbian Buster Lite, alors le processus de démarrage des services se fait avec _systemd_. Celui-ci nécessite des fichiers `.service` dans le dossier `/etc/systemd/system/` pour tous les services qu'il peut gérer. Ainsi, il faut créer ces fichiers et y définir les paramètres voulus pour chaques composants.

Après s'être diriger dans le bon dossier via `cd /etc/systemd/system/`, il faut faire `sudo nano nom-du-service.service`, où _nom-du-service.service_ est un des fichiers ci-dessous. Puis il faut copier le contenu respectif et répéter le tout pour chacun des services requis :

- **movit_backend.service**
```bash
[Unit]
Description=-------- MOVIT+ BACKEND with node-red
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=pi
ExecStart=/usr/local/bin/node-red-pi -u /home/pi/MOvIT-Detect-Backend --max-old-space-size=256

[Install]
WantedBy=multi-user.target
```

- **movit_frontend.service**
```bash
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
WorkingDirectory=/home/pi/MOvIT-Detect-Frontend/

[Install]
WantedBy=multi-user.target
```


- **movit_acquisition.service**
```bash
[Unit]
Description=-------- MOVIT+ acquisition software
After=network-online.target mosquitto.service
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/home/pi/MOvIT-Detect/Movit-Pi/Executables/movit-pi

[Install]
WantedBy=multi-user.target
```



### 2.2. Utilisation des services
Afin que les services soit lancés au démarrage, les commandes suivantes sont essentielles :
```bash
sudo systemctl enable movit_backend.service
sudo systemctl enable movit_frontend.service
sudo systemctl enable movit_acquisition.service
```

Il sera probablement nécessaire d'effectuer la commande suivante pour pouvoir utiliser et tester les services immédiatement sans redémarrer le système :
```bash
sudo systemctl daemon-reload
```
Il est possible de connaitre l'état, arrêter et partir les services avec les commandes suivantes
```bash
systemctl status nom-du-service.service
sudo systemctl start nom-du-service.service
sudo systemctl stop nom-du-service.service
```

Les commandes suivantes listent les services qui seront lancé au démarrage :
```bash
systemctl list-unit-files | grep enabled
systemctl list-unit-files | grep disabled
```
> [Exemple de réponse](https://pastebin.com/iXuyHpXC) d'un des systèmes fonctionnels lors de l'exécution de ces commandes pour référence...

### 2.3. Optimisation du temps de démarrage
Certains services et certaines fonctionnalités peuvent être désactivées pour accélérer le démarrage du RaspberryPi :
```bash
echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt #Désactive le bluetooth
sudo systemctl disable hciuart #Service systemd qui initialise le Bluetooth
sudo systemctl disable dnsmasq #Celui-ci est démarré à l'aide du script plus haut
```
Voir l'exemple de réponse plus haut aux commandes `systemctl list-unit-files` pour plus de détails.
D'autres optimisations pourraient être faites, notamment en utilisant une version de Linux comportant uniquement les fonctionnalités nécessaires.
___

<br>
<br>

# 3. Installation de MOvIT +
Les instructions d'installation des composantes de Movit + sont disponibles dans les `README.md` des répertoires GitHub correspondants.
L'installation devrait ainsi se faire dans l'ordre suivant :
- **MOvIT-Detect :** Capteurs, code d’acquisition en C++ et communication avec les bus I2C

- **MOvIT-Detect-Frontend :** Code en JavaScript permettant l’affichage d’une page web et l’interaction avec les couches inférieures

- **MOvIT-Detect-Backend :** Code sous forme graphique avec Node-Red, base de données Mongo et communication entre toutes ces parties
___

<br>
<br>

# 4. Mises à jour du système
Un système de mise à jour sera mis en place dans le futur, afin de facilement pouvoir utilser les dernières versions développées, probablement en entrant une seule ligne de commande.

    Documentation à venir...
    
___

<br>
<br>
