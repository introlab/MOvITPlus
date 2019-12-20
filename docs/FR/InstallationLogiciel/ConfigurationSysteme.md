
# Configuration du système

## Table des matières :
- [Configuration du système](#configuration-du-syst%c3%a8me)
  - [Table des matières :](#table-des-mati%c3%a8res)
- [1. Image système](#1-image-syst%c3%a8me)
    - [1.1. Image de base](#11-image-de-base)
    - [1.2. Image préconfiguré](#12-image-pr%c3%a9configur%c3%a9)
        - [Script d'initialisation](#script-dinitialisation)
    - [1.3 Flashage d'une image](#13-flashage-dune-image)
    - [1.4 Utilisation en mode _headless_](#14-utilisation-en-mode-headless)
- [2. Configuration réseau](#2-configuration-r%c3%a9seau)
    - [2.1. Connection à un réseau wi-fi](#21-connection-%c3%a0-un-r%c3%a9seau-wi-fi)
    - [2.2. Activation du SSH](#22-activation-du-ssh)
    - [2.3. Changment du Hostname et du mot de passe](#23-changment-du-hostname-et-du-mot-de-passe)
        - [Obtention de l'addresse MAC :](#obtention-de-laddresse-mac)
        - [Hostname :](#hostname)
        - [Mot de passe :](#mot-de-passe)
    - [2.4. Ajout de l'_access point_ comme interface](#24-ajout-de-laccess-point-comme-interface)
    - [2.5. Configuration de DNSmasq et Hostapd](#25-configuration-de-dnsmasq-et-hostapd)
        - [Installation des logiciels :](#installation-des-logiciels)
        - [Configuration de DNSmasq :](#configuration-de-dnsmasq)
        - [Configuration de HostAPd :](#configuration-de-hostapd)
    - [2.6. Configuration des interfaces](#26-configuration-des-interfaces)
    - [2.7. Configuration du nom de domaine](#27-configuration-du-nom-de-domaine)
    - [2.8. Partage de connexion](#28-partage-de-connexion)
        - [Configuration des IPtables](#configuration-des-iptables)
        - [IPtables au démarrage](#iptables-au-d%c3%a9marrage)
    - [2.9. Démarrage du point d'accès](#29-d%c3%a9marrage-du-point-dacc%c3%a8s)
    - [2.10. Finalisation](#210-finalisation)
    - [2.11. Conclusion](#211-conclusion)
- [3. Configuration du démarrage](#3-configuration-du-d%c3%a9marrage)
    - [3.1. Services avec systemd](#31-services-avec-systemd)
    - [3.2. Utilisation des services](#32-utilisation-des-services)
    - [3.3. Optimisation du temps de démarrage](#33-optimisation-du-temps-de-d%c3%a9marrage)
- [4. Installation de MOvIT +](#4-installation-de-movit)
    - [Installation de GitHub](#installation-de-github)
    - [Installation initiale de MOvIt Plus](#installation-initiale-de-movit-plus)
    - [Installation complémentaire](#installation-compl%c3%a9mentaire)
- [5. Mises à jour du système](#5-mises-%c3%a0-jour-du-syst%c3%a8me)
    - [Mise à jour du projet par script](#mise-%c3%a0-jour-du-projet-par-script)
    - [Mise à jour du projet manuellement](#mise-%c3%a0-jour-du-projet-manuellement)
___
<br>
<br>

# 1. Image système
### 1.1. Image de base
L'entièreté des configurations ci-dessous sont basées sur une image de [Rasbian Buster](https://www.raspberrypi.org/downloads/raspbian/ "Site de téléchargement pour l'image Rasbian"). La dernière version testée est la révision de septembre 2019 déployé le 26 septembre. Il est important d'utiliser la version dite "Lite", qui n'a pas d'interface utilisateur, afin de réduire considérablement la charge de travaille sur le RaspberryPi Zero W.

### 1.2. Image préconfiguré
Une image du système préconfiguré, incluant un script de démarrage sur mesure, est disponible sur le GitHub du projet directment. Utiliser cette image permet notamment d'éviter d'avoir à faire toutes les étapes de configuration qui suivent. 
Il peut cependant être utile de faire toute cette configuration manuellement pour mettre à jour l'image de base de Rasbian ou simplement pour permettre une meilleure compréhension du système.

##### Script d'initialisation
Certaines configurations, notamment le changement du _hostname_, du nom du point d'accès et de l'addresse MAC dans l'interface pour le point d'accès, sont réalisées avec un script qui s'exécute au premier démarrage puis se supprime. Celui-ci laisse des traces dans le fichier `/home/pi/MOvITPlus/firstBootSetup.log`. Le script est disponible dans ce répertoire GitHub au besoin.
Si un problème survient ou que l'initialisation doit être réactivée à nouveau, le script peut être déclanché avec la commande `sudo /home/pi/MOvITPlus/./firstBootSetup.sh`. L'ajout de l'option `--restore` à la fin de cette commande permet de réactiver l'exécution du script lors du prochain boot au besoin.



### 1.3 Flashage d'une image
[Balena Etcher](https://www.balena.io/etcher/ "Site officiel de Balena Etcher") est le logiciel utilisé pour _flasher_ l'image désiré sur une carte micro-SD facilement.

### 1.4 Utilisation en mode _headless_
Le mode headless permet de ne pas recourir à un clavier et un écran branché à l'appareil et de simplement fonctionner par SSH. Il peut cependant être nécessaire d'utiliser un écran et un clavier dans les cas où un erreur qui pertube la connection réseau de l'appareil survient. Les méthodes pour démarrer, au premier lancement, en mode _headless_ sont contenues dans les notes "**Utilisation headless**" des sections [2.1. Connection à un réseau wi-fi](#21-connection-à-un-réseau-wi-fi) et [2.2. Activation du SSH](#22-activation-du-ssh).
___

<br>
<br>

# 2. Configuration réseau
Il est possible d'utiliser la carte réseau du Raspberry Pi Zero W à la fois comme client et point d'accès. Ce point d'accès peut ainsi fournir à la fois une connection internet et une connection à l'interface web du projet. Les instructions sont tirées principalement d'[ici](https://community.ptc.com/t5/IoT-Tech-Tips/Using-the-Raspberry-Pi-as-a-WIFI-hotspot/td-p/535058).

Fonctionnement en bref :
- **ifupdown :** Met en fonction les connections sans fil configurées. Deux instances de ifup sont créées; **ifup@wlan0**, pour la connection au wi-fi, et **ifup@ap0**, pour la gestion du point d'accès. Ces instances font appels à **wpa_supplicant** / **_dhclient_** et **hostapd** respectivement.
  - **wpa_supplicant / dhclient :** Gère la connection à d'autres points d'accès wi-fi
  - **hostapd :** Permet la création d'un point d'accès à même le RaspberryPi
- **dnsmasq :** Fournit les services DHCP, soit l'assignation d'addresse IP aux appareils connectés à un réseau (AP), et DNS, soit l'utilisation de l'addresse [movit.plus](http://movit.plus) à la place de [192.168.10.1](http://192.168.10.1).
- **Avahi :** Permet la communication et l'échange de services sur les réseaux configurés via le protocole mDNS/DNS-SD. Utile notamment pour l'accès à l'addresse _hostname-de-l'appareil_.local pour ouvrir une session en **ssh**.
  - **ssh :** Permet la connection à distance à la console du RaspberryPi, pour fonctionner sans l'aide d'un écran/clavier branché au RaspberryPi (headless mode), voir les notes dans les étapes plus bas.

### 2.1. Connection à un réseau wi-fi
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

Il faut évidemment remplacer `SSID` et `MOT_DE_PASSE` par des identifiants réseau valides. La clé `id_str` permet de définir une priorité réseau. Pour ajouter d'autres réseaux (_wifi roaming_), il faut incrémenter `AP1` (`AP2`, `AP3`...).

> Il est aussi possible d'utiliser l'utilitaire `raspi-config` pour réaliser l'équivalent de ces étapes à l'aide d'un interface utilisateur.

> **Utilisation headless :** le fichier `wpa_supplicant.conf` dûment remplit peut être placé dans la partition boot d'une carte SD nouvellement flashé. Le système déplacera alors ce fichier au bon endroit et l'utilisera afin de permettre une connection au wifi voulu dès le premier démarrage.

### 2.2. Activation du SSH
Secure Shell (SSH) peux être activé à l'aide du menu _raspi-config_ ou en utilisant `sudo systemctl enable ssh`_(prochain démarrage)_ et `sudo systemctl start ssh`_(immédiat seulement)_.
> **Utilisation headless :** Il peut également être activé en plaçant un fichier vide et sans extension, nommé `ssh`, dans la partition de boot de l'image fraichement flashée.

### 2.3. Changment du Hostname et du mot de passe
Il est préférable que le Hostname et le nom de l'_access point_ soient du format `movit-xxyyzz` où xxyyzz représente les derniers octets de l'addresse MAC de l'appareil configuré. Ce format, également utilisé pour le nom du point d'accès plus bas, permet d'éviter des conflits de Hostname sur même réseau ou de la confusion entre les points d'accès.

##### Obtention de l'addresse MAC :
Pour procéder, il faut donc connaitre l'adresse MAC de l'interface `wlan0`. La commande suivante devrait retourner l'addresse directement :
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
>                addr b8:27:eb:xx:yy:zz
>                ssid <YOUR HOME SSID> 
>                type managed
>                channel 6 (2437 MHz), width: 20 MHz, center1: 2437 MHz
>                txpower 31.00 dBm
>```
>L'adresse MAC de ce Raspberry Pi se trouve sous Inteface wlan0 > addr, dans notre situation l'adresse MAC de l’Interface wlan0 serait b8:27:eb:xx:yy:zz.

##### Hostname :
Ensuite, il faut changer `raspberrypi`, le Hostname par défaut, pour `movit-xxyyzz` dans
les fichiers `/etc/hostname` et `/etc/hosts`. Ces changements peuvent aussi être réalisés en utilisant le menu _raspi-config_.

##### Mot de passe :
Pour changer le mot de passe, la commande `passwd` permet de choisir un mot de passe après avoir entré le mot de passe précédant, soit `raspberry` pour une installation fraîche de Rasbian.  Il est recommendé que le nouveau mot de passe soit `movitdev` par soucis d'uniformité entre les appareils.

### 2.4. Ajout de l'_access point_ comme interface
Il faut créer une règle udev qui va ajouter le point d'accès virtuel, et le lier a l'interface par défaut du RaspberryPi Zero soit `wlan0`. Il faudra modifier ou créer le fichier `/etc/udev/rules.d/70-persistent-net.rules` à l'aide de votre éditeur favori. Il faut inscrire dans le fichier les éléments suivants tout en prenant soin de remplacer l'adresse MAC par celle découverte précédemment:
```bash
SUBSYSTEM=="ieee80211", ACTION=="add|change", ATTR{macaddress}=="b8:27:eb:xx:yy:zz", KERNEL=="phy0", \
  RUN+="/sbin/iw phy phy0 interface add ap0 type __ap", \
  RUN+="/bin/ip link set ap0 address b8:27:eb:xx:yy:zz"
```
La seconde adresse MAC est celle de notre AP virtuel, il peut être changé ou être le même que celui de `wlan0`, cela ne semble pas causer de problème.

### 2.5. Configuration de DNSmasq et Hostapd
Ces deux programmes vont nous permettre de créer un point d'accès sur notre interface `ap0`, et de créer un serveur DHCP sur celui-ci pour pouvoir gérer les clients connectés sur l'AP (_access point_).

##### Installation des logiciels :
Avant d'installer ces logiciels, il est nécessaire de faire la commande suivante pour mettre à jour toutes les composantes du système fraichement installé.
```bash
sudo apt-get update
```

Ensuite, pour installer ces logiciels, il faut effectuer la commande suivante:
```bash
sudo apt-get install dnsmasq hostapd -y
```
Il faut également désactiver wpa_supplicant.service
```bash
systemctl disable wpa_supplicant.service
```
##### Configuration de DNSmasq :
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


##### Configuration de HostAPd :
> Un redémarrage peut être nécessaire pour permettre à HostAPd de terminer son installation.

Il faut ensuite modifier le fichier `/etc/hostapd/hostapd.conf` pour y écrire la configuration suivante : 
```bash
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=ap0
driver=nl80211
ssid=Movit-xxyyzz
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
```

Il faut remplacer le ssid (nom du réseau) actuellement `Movit-xxyyzz` et remplacer _xxyyzz_ par les derniers octets de l'[addresse MAC](#obtention-de-laddresse-mac) comme précédement. Il est recommendé que le mot de passe du point d'accès, représenté ici arpès `wpa_passphrase=`, soit `movitplus` par soucis d'uniformité entre les appareils. Si changé, ce mot de passe doit avoir un minimum de 8 caractères pour respecter la norme WPA.

Ensuite, le fichier `/etc/default/hostapd` doit être modifié de façon à changer la clé `DAEMON_CONF`. Cette ligne fait comprendre à HostAPd où il doit lire son fichier de configuration au démarrage. Il faut la remplacer par :
```bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```


### 2.6. Configuration des interfaces 
Il faut ensuite modifier `/etc/network/interfaces` afin d'activer les interfaces réseau et leur assigner une adresse IP statique. Le fichier devrait contenir ceci après la modification :
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


### 2.7. Configuration du nom de domaine
DNSmasq lit le fichier `/etc/hosts` afin d'associer certaines addresses à des noms de domaines. Cette fonction est utilisée pour rediriger le traffic vers le la bonne addresse si une tentative est faite pour se connecter aux noms de domaines spécifiés. À ce fichier, il faut **ajouter ces lignes à la fin** :
```bash
#Allows access to the frontend and the backend with an easier to remember address:
192.168.10.1	movit	movit.plus
``` 


### 2.8. Partage de connexion
Un fichier de configuration doit être modifié pour permettre d'activer le partage de connection internet entre les deux interfaces, soit wlan0 et ap0. Ainsi, dans `/etc/sysctl.conf`, il faut décommenter la ligne `net.ipv4.ip_forward=1`. Il faut ensuite exécuter la commande `sudo sysctl -p /etc/sysctl.conf` pour mettre en effet ces changements.

##### Configuration des IPtables
Ensuite, pour permettre la transcription des addresses IP pour compléter la connection à internet, il faut exécuter la commande suivante :
```bash
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
```
##### IPtables au démarrage
Pour rendre ces règles persistentes, _iptables-persistent_ est la meilleure solution. Pour l'installer :
```bash
sudo apt-get install iptables-persistent
```
Lorsque demandé, il faut appuyer sur _oui_ pour sauvegarder les règles actuelles.


### 2.9. Démarrage du point d'accès
DNSmasq doit démarrer au bon moment pour fonctionner correctement. Pour assurer cela, il faut modifier une ligne dans son fichier _.service_ de façon à ce qu'il démarre uniquement lorsque le démarrage des réseaux est complété. Dans le fichier `/lib/systemd/system/dnsmasq.service`, il faut ajouter "network-online.target" à ces deux lignes sous [Unit] :
```bash
Wants=nss-lookup.target network-online.target
After=network.target network-online.target
```
Si DNSmasq n'est pas activé au démarrage, cette commande permettra de le faire : `sudo systemctl enable dnsmasq.service`. Cependant, il devrait déjà l'être.

### 2.10. Finalisation
Pour finir, il faut activer `systemd-networkd-wait-online.service` qui s'occupe d'activer `network-online.target` pour l'utilisation des services qui nécessite l'accès à internet au démarrage. Il faut également s'assurer que `networking.service` est activé puisqu'il gère le processus mis en place plus haut.
```bash
systemctl enable systemd-networkd-wait-online.service
systemctl enable networking.service
```

### 2.11. Conclusion
Une fois que toutes ces étapes sont complétées, il est possible de redémarrer le Raspberry Pi. L'AP deviendra alors visible et accessible. Il permettra une connection internet en passant par le réseau auquel il est connecté et il offrira une connection aux serveurs qu'il exécutera par le biais de l'addresse [movit.plus](http://movit.plus).
>Les services qui devrait être actif ainsi que les instances qu'ils contrôlent après un redémarrage devraient être les suivants :
> - systemd-networkd-wait-online.service
> - networking.service
> - ifup@wlan0.service
>     - wpa_supplicant
>     - wpa_cli
>     - dhclient
> - ifup@ap0.service
>     - hostapd
> - dnsmasq.service
>
>Il est ainsi possible de regarder leur status avec
>```bash
> systemctl status nom_du_.service 
>``` 

___

<br>
<br>

# 3. Configuration du démarrage
Le démarrage des différents services créés pour le projet est l'élément crucial permettant au RasbperryPi Zero d'exécuter le code conçu dès le branchement de l'appareil.
### 3.1. Services avec systemd
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
ExecStart=/usr/local/bin/node-red-pi -u /home/pi/MOvITPlus/MOvIT-Detect-Backend --max-old-space-size=256

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
WorkingDirectory=/home/pi/MOvITPlus/MOvIT-Detect-Frontend/

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

```

> Aussi, si désiré, un service permettant l'activation au démarrage du script `firstBootSetup.sh` peut être ajouté :
> - **movit_setup.service**
> ```bash
> [Unit]
> Description=-------> MOVIT+ first boot setup script
> After=network-online.target dnsmasq.service rc-local.service
> Wants=network-online.target
>
> [Service]
> # Increase process niceness (priority) for faster execution
> Nice=-10
> Type=forking
> User=root
> ExecStart=/home/pi/firstBootSetup.sh --fromService
> TimeoutStartSec=40min 00s
> ExecStartPost=reboot
>
> [Install]
> WantedBy=multi-user.target
> ```


### 3.2. Utilisation des services
Afin que les services soit lancés au démarrage, les commandes suivantes sont essentielles :
```bash
sudo systemctl enable movit_backend.service
sudo systemctl enable movit_frontend.service
sudo systemctl enable movit_acquisition.service
```

> Il est recommandé de **ne pas activer ces services avant la fin de l'installation du projet**
> Voir la section [Installation de MOvIT +](#4-installation-de-movit)

Pour pouvoir utiliser et tester les services immédiatement sans redémarrer le système, il sera nécessaire d'effectuer la commande suivante :
```bash
sudo systemctl daemon-reload
```

Il est possible de connaitre l'état, arrêter et partir les services avec les commandes suivantes :
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
> [Exemple de réponse](https://pastebin.com/shxSRXkR) d'un des systèmes fonctionnels lors de l'exécution de ces commandes.

### 3.3. Optimisation du temps de démarrage
Certains services et certaines fonctionnalités peuvent être désactivées pour accélérer le démarrage du RaspberryPi. Dans le fichier `/boot/config.txt`, il faut ajouter ces lignes à la fin :
```bash
#disable bluetooth
dtoverlay=pi3-disable-bt

#---------Tested, seems fine
# Disable the rainbow splash screen
disable_splash=1

# Overclock the SD Card from 50 to 100MHz
# This can only be done with at least a UHS Class 1 card
dtoverlay=sdtweak,overclock_50=100

# Set the bootloader delay to 0 seconds. The default is 1s if not specified.
boot_delay=0
```
Il faut également exécuter ces commandes :
```bash
sudo systemctl disable hciuart #Service systemd qui initialise le Bluetooth
sudo systemctl disable dhcpcd.service #Service de dhcpcd inutile
systemctl disable triggerhappy.service
systemctl disable triggerhappy.socket
```

Voir l'exemple de réponse plus haut aux commandes `systemctl list-unit-files` pour plus de détails.
D'autres optimisations pourraient être faites, notamment en utilisant une version de Linux comportant uniquement les fonctionnalités nécessaires.
___

<br>
<br>

# 4. Installation de MOvIT +
> Voir le README du répertoire parent pour plus de détails sur les différentes partie du projet.
### Installation de GitHub
Si _git_ n'est pas installé, il faut exécuter cette commande : `sudo apt-get install -y git`

### Installation initiale de MOvIt Plus

L'installation de MOvIt requiert un `git clone` habituel, mais comporte quelques subtilités avec les sous-modules. Ce répertoire devrait être installé sous `home/pi/`. La commande suivante installe tous les dossiers nécessaires, y compris les sous répertoires.
```bash
git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules
```
### Installation complémentaire

Cepandant, plusieurs autres étapes sont nécessaires au fonctionnement du projet. Les instructions d'installation du reste des composantes de Movit Plus sont disponibles dans les `README.md` des répertoires GitHub correspondants. L'installation selon ces guides devrait ainsi se faire dans l'ordre suivant :
1. **MOvIT-Detect :** Capteurs, code d’acquisition en C++ et communication avec les bus I2C
2. **MOvIT-Detect-Frontend :** Code en JavaScript permettant l’affichage d’une page web et l’interaction avec les couches inférieures
3. **MOvIT-Detect-Backend :** Code sous forme graphique avec Node-Red, base de données Mongo et communication entre toutes ces parties
___

<br>
<br>

# 5. Mises à jour du système
### Mise à jour du projet par script
Si une mise à jour est disponible, il faut simplement exécuter le script `updateProject.sh`. Or, pour permettre l'exécution de commandes potentiellements ajoutés au script de mise à jour, il est préférable d'aller chercher et d'exécuter le script le plus récent avec la commande suivante. 
```bash
curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
```

Voir la documentation sur le [script de mise à jour](https://github.com/introlab/MOvITPlus#script-de-mise-%c3%a0-jour).

### Mise à jour du projet manuellement
Une des parties de la mise est jour est simplement l'utilisation de la commande `git pull` dans le dossier parent. En plus du `git pull` habituel, il peut être nécessaire de mettre à jour les sous-répertoires également :
```bash
git pull
git submodule update --init --recursive
```
- Charge les versions des sous-répertoires liées (tag de versions des sous-répertoires)
- Met à jour les scripts et les autres fichiers contenus par le répertoire parent
> Les services devraient être arrêté avant de procéder ainsi. L'utilisation du script est préférable.
___

<br>
<br>
