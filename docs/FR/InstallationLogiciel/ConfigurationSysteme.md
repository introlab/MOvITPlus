
# Configuration du système

## Table des matières :
- [Configuration du système](#configuration-du-système)
  - [Table des matières :](#table-des-matières-)
- [1. Requis](#1-requis)
- [2. Image système](#2-image-système)
  - [2.1. Image officielle de base](#21-image-officielle-de-base)
  - [2.2. Image préconfigurée](#22-image-préconfigurée)
  - [2.3 Flashage d'une image](#23-flashage-dune-image)
- [3. Configuration système de base](#3-configuration-système-de-base)
  - [3.1 Configuration du hostname et activation des périphériques](#31-configuration-du-hostname-et-activation-des-périphériques)
- [3.2 Installation des dépendances / paquets](#32-installation-des-dépendances--paquets)
- [3.3 Changer le mot de passe](#33-changer-le-mot-de-passe)
- [3.4. Configuration de DNSmasq et Hostapd](#34-configuration-de-dnsmasq-et-hostapd)
  - [Installation des logiciels :](#installation-des-logiciels-)
  - [Configuration de DNSmasq :](#configuration-de-dnsmasq-)
  - [Configuration de HostAPd :](#configuration-de-hostapd-)
    - [3.6. Configuration des interfaces statiques](#36-configuration-des-interfaces-statiques)
    - [3.7. Configuration du nom de domaine](#37-configuration-du-nom-de-domaine)
    - [3.8 Configuration de l'interface wifi1 (USB) ayant accès à Internet](#38-configuration-de-linterface-wifi1-usb-ayant-accès-à-internet)
    - [3.9. Partage de connexion](#39-partage-de-connexion)
  - [Configuration des IPtables](#configuration-des-iptables)
  - [IPtables au démarrage](#iptables-au-démarrage)
    - [3.10. Démarrage du point d'accès](#310-démarrage-du-point-daccès)
    - [3.11. Network Online Service](#311-network-online-service)
    - [3.12. Redémarrage](#312-redémarrage)
- [4. Installation de l'application MOvIT+](#4-installation-de-lapplication-movit)
  - [4.1 Téléchargement du code à partir de GitHub](#41-téléchargement-du-code-à-partir-de-github)
  - [4.2 Installation des sous-systèmes](#42-installation-des-sous-systèmes)
- [5. Configuration du démarrage](#5-configuration-du-démarrage)
  - [5.1. Services avec systemd](#51-services-avec-systemd)
  - [5.2. Utilisation des services](#52-utilisation-des-services)
- [6. Optimisation du temps de démarrage](#6-optimisation-du-temps-de-démarrage)
- [7. Mises à jour du système](#7-mises-à-jour-du-système)
  - [Mise à jour du projet manuellement](#mise-à-jour-du-projet-manuellement)
___
<br>
<br>

# 1. Requis

>**Nous supposons ici que nous possédons deux interfaces WiFi, celle qui est intégrée dans le RaspberryPi (wifi0) et un dongle USB WiFi (wifi1)**. L'interface wifi0 sera configurée pour le point d'accès et l'interface wifi1 sera configurée comme client wifi pour l'accès Internet. Si vous n'avez pas de dongle WiFi, vous pouvez utilisez la connection câblée (eth0) pour la configuration.

> L'interface PCB [MOvIT-Hardware pour Raspberry Pi 3/4] doit être installée sur le connecteur 40 pins du RaspberryPi.

# 2. Image système
## 2.1. Image officielle de base
L'entièreté des configurations ci-dessous sont basées sur une image de [Raspberry Pi OS](https://www.raspberrypi.org/downloads/raspberry-pi-os/ "Site de téléchargement pour l'image Raspberry Pi OS") le plus récent. 

> La dernière version testée est la révision de May 2020.

> Nous recommandons d'utiliser la version _Raspberry Pi OS (32-bit) with desktop_, la version 64 bits n'étant pas disponible en ce moment.

> **Utilisation headless :** le fichier `wpa_supplicant.conf` dûment rempli peut être placé dans la partition boot d'une carte SD nouvellement flashé. Le système déplacera alors ce fichier au bon endroit et l'utilisera afin de permettre une connection au wifi voulue dès le premier démarrage.

> **Utilisation headless :** SSH peut également être activé en plaçant un fichier vide et sans extension, nommé `ssh`, dans la partition de boot de l'image fraîchement flashée.


## 2.2. Image préconfigurée
> N'est pas à jour. Utilisez la configuration système de base pour l'instant.
Une image du système préconfiguré est disponible dans la section ["Releases"](https://github.com/introlab/MOvITPlus/releases) sur GitHub directment. Utiliser la dernière version de cette image permet notamment d'éviter d'avoir à faire toutes les étapes de configuration qui suivent. 
Il peut cependant être utile de faire toute cette configuration manuellement pour mettre à jour l'image de base de RaspberryPi OS ou simplement pour permettre une meilleure compréhension du système.

## 2.3 Flashage d'une image
[Balena Etcher](https://www.balena.io/etcher/ "Site officiel de Balena Etcher") est le logiciel utilisé pour _flasher_ l'image désirée sur une carte micro-SD facilement.
___
# 3. Configuration système de base

Veuillez suivre les étapes ci-dessous dans l'ordre. 

## 3.1 Configuration du hostname et activation des périphériques

Nous allons d'abord utiliser l'outil `raspi-config` pour les premières configurations.

1. Ouvrir un terminal à partir du bureau
2. lancer la commande:
```bash
raspi-config
```
3. Sélectionnez `2-Network Options -> Hostname` et donnez le nom `movit-xxyyzz` à votre système où xxyyzz représente les derniers octets de l'addresse MAC de l'appareil configuré. Ce format, également utilisé pour le nom du point d'accès plus tard, permet d'éviter les conflits de noms sur le même réseau ou la confusion entre les points d'accès si vous avez plusieurs systèmes MOvIT+ dans votre établissement. L'obtention de l'adresse MAC s'effectue par la commande suivante sur un terminal :
```bash
ifconfig wlan0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
```
4. Activez SSH
5. Activez I2C
6. Activez SPI
7. Configurez WiFi Client


>Vous allez avoir besoin d'un accès Internet pour les étapes suivantes. Un redémarrage peut être nécessaire.

# 3.2 Installation des dépendances / paquets

Toujours dans le terminal, installez les paquets avec les commandes suivantes :

```bash
# Source de nodejs 10.x
sudo wget -qO- https://deb.nodesource.com/setup_10.x | sudo bash -

# Update la liste des packages
sudo apt-get update

# Installation (tout sur la même ligne)
sudo apt-get install -y vim i2c-tools build-essential cmake mosquitto git libmosquittopp-dev mosquitto-clients mongodb mongodb-server libkrb5-dev libzmq3-dev nodejs yarn python3 python3-venv
```

# 3.3 Changer le mot de passe
Pour changer le mot de passe, la commande `passwd` permet de choisir un mot de passe après avoir entré le mot de passe précédant, soit `raspberry` pour une installation fraîche de Rasbian.  Il est recommandé que le nouveau mot de passe soit `movitdev` par soucis d'uniformité entre les appareils.


# 3.4. Configuration de DNSmasq et Hostapd
Ces deux programmes vont nous permettre de créer un point d'accès sur notre interface `wlan0`, et de créer un serveur DHCP sur celui-ci pour pouvoir gérer les clients connectés sur l'AP (_access point_).

## Installation des logiciels :
Avant d'installer ces logiciels, il est nécessaire de faire la commande suivante pour mettre à jour toutes les composantes du système fraîchement installé.
```bash
sudo apt-get update
sudo apt-get install dnsmasq hostapd -y
```

## Configuration de DNSmasq :
Suite à cette commande, il faut mettre en place quelques fichiers de configuration. Le premier fichier à modifier est `/etc/dnsmasq.conf` dans lequel il faut ajouter quelques lignes à la fin, voici ces lignes:
```bash
interface=lo,wlan0
no-dhcp-interface=lo,eth0
bind-interfaces
server=8.8.8.8
domain-needed
bogus-priv
dhcp-range=192.168.10.50,192.168.10.150,12h
```
Les adresses IP données par dnsmasq débuteront ainsi à `192.168.10.50` jusqu'à `192.168.10.150`.


## Configuration de HostAPd :
> Un redémarrage peut être nécessaire pour permettre à HostAPd de terminer son installation.

Il faut ensuite modifier le fichier `/etc/hostapd/hostapd.conf` pour y écrire la configuration suivante : 
```bash
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=wlan0
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

Il faut remplacer le ssid (nom du réseau) actuellement `Movit-xxyyzz` et remplacer _xxyyzz_ par les derniers octets de l'[addresse MAC](#obtention-de-laddresse-mac) comme précédemment. Il est recommandé que le mot de passe du point d'accès, représenté ici après `wpa_passphrase=`, soit `movitplus` par soucis d'uniformité entre les appareils. Si modifié, ce mot de passe doit avoir un minimum de 8 caractères pour respecter la norme WPA.

Ensuite, le fichier `/etc/default/hostapd` doit être modifié de façon à changer la clé `DAEMON_CONF`. Cette ligne fait comprendre à HostAPd où il doit lire son fichier de configuration au démarrage. Il faut la remplacer par :
```bash
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

### 3.6. Configuration des interfaces statiques

La configuration des adresses IP peut s'effectuer dans le fichier `/etc/dhcpcd.conf`. **Ajoutez les lignes suivantes à la fin** :

```bash
interface wlan0
static ip_address=192.168.10.1/24
nohook wpa_supplicant
``` 

### 3.7. Configuration du nom de domaine
DNSmasq lit le fichier `/etc/hosts` afin d'associer certaines addresses à des noms de domaines. Cette fonction est utilisée pour rediriger le trafic vers la bonne addresse si une tentative est faite pour se connecter aux noms de domaines spécifiés. À ce fichier, il faut **ajouter ces lignes à la fin** :
```bash
#Un nom plus facile à retenir
192.168.10.1	movit	movit.plus
``` 

### 3.8 Configuration de l'interface wifi1 (USB) ayant accès à Internet

Assurez-vous que le fichier `/etc/wpa_supplicant/wpa_supplicant.conf` contient les bonnes informations qui seront utilisées par l'interface wifi1.

```bash
country=CA
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="NOM_DU_RESEAU" #Remplacer NOM_DU_RESEAU par le nom du réseau désiré
    psk="MOT_DE_PASSE" #Remplacer MOT_DE_PASSE par le mot de passe de celui-ci
    id_str="AP1"
}
```

### 3.9. Partage de connexion
Un fichier de configuration doit être modifié pour permettre d'activer le partage de connection internet entre les deux interfaces, soit wlan0 et wlan1 (ou eth0). Ainsi, dans `/etc/sysctl.conf`, il faut décommenter la ligne `net.ipv4.ip_forward=1`. Il faut ensuite exécuter la commande `sudo sysctl -p /etc/sysctl.conf` pour mettre en effet ces changements.

## Configuration des IPtables
Ensuite, pour permettre la transcription des addresses IP pour compléter la connection à internet, il faut exécuter la commande suivante :
```bash
sudo iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
```
## IPtables au démarrage
Pour rendre ces règles persistantes, _iptables-persistent_ est la meilleure solution. Pour l'installer :
```bash
sudo apt-get install iptables-persistent
```
Lorsque demandé, il faut appuyer sur _oui_ pour sauvegarder les règles actuelles.

### 3.10. Démarrage du point d'accès
DNSmasq doit démarrer au bon moment pour fonctionner correctement. Pour assurer cela, il faut modifier une ligne dans son fichier _.service_ de façon à ce qu'il démarre uniquement lorsque le démarrage des réseaux est complété. Dans le fichier `/lib/systemd/system/dnsmasq.service`, il faut ajouter "network-online.target" à ces deux lignes sous [Unit] :
```bash
Wants=nss-lookup.target network-online.target
After=network.target network-online.target
```
Si DNSmasq n'est pas activé au démarrage, cette commande permettra de le faire : `sudo systemctl enable dnsmasq.service`. Cependant, il devrait déjà l'être.

### 3.11. Network Online Service
Pour finir, il faut activer `systemd-networkd-wait-online.service` qui s'occupe d'activer `network-online.target` pour l'utilisation des services qui nécessite l'accès à internet au démarrage. Il faut également s'assurer que `networking.service` est activé puisqu'il gère le processus mis en place plus haut.
```bash
systemctl enable systemd-networkd-wait-online.service
systemctl enable networking.service
```

### 3.12. Redémarrage
Une fois que toutes ces étapes sont complétées, il est nécessaire de redémarrer le Raspberry Pi. L'AP deviendra alors visible et accessible. Il permettra une connexion internet en passant par le point d'accés local nommé movit-xxyyzz. Testez votre connexion réseau et continuez à l'étape 4.
___


# 4. Installation de l'application MOvIT+
> Voir le README.md du répertoire parent pour plus de détails sur les différentes partie du projet.

## 4.1 Téléchargement du code à partir de GitHub

L'installation de MOvIt requiert un `git clone` habituel, mais comporte quelques subtilités avec les sous-modules. Ce répertoire devrait être installé sous `home/pi/`. La commande suivante installe tous les dossiers nécessaires, y compris les sous répertoires.
```bash
git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules
```
## 4.2 Installation des sous-systèmes

Plusieurs autres étapes sont nécessaires au fonctionnement du projet. Les instructions d'installation du reste des composantes de MOvIT+ sont disponibles dans les `README.md` des répertoires GitHub correspondants. L'installation selon ces guides devrait ainsi se faire dans l'ordre suivant :
1. **[MOvIT-Detect](https://github.com/introlab/MOvIT-Detect/blob/master/README.md) :** Capteurs, code d’acquisition en C++ et communication avec le bus I2C et les périphériques.
2. **[MOvIT-Detect-Backend](https://github.com/introlab/MOvIT-Detect-Backend/blob/master/README.md) :** Code sous forme graphique avec Node-Red, base de données Mongo et communication entre toutes ces parties
3. **[MOvIT-Detect-Frontend](https://github.com/introlab/MOvIT-Detect-Frontend/blob/master/README.md) :** Code en JavaScript permettant l’affichage d’une page web et l’interaction avec les couches inférieures
___


# 5. Configuration du démarrage
Le démarrage des différents services créés pour le projet est l'élément crucial permettant au RasbperryPi d'exécuter le code conçu dès le branchement de l'appareil.
## 5.1. Services avec systemd
Puisque l'image utilisée est Raspbian Buster Lite, alors le processus de démarrage des services se fait avec _systemd_. Celui-ci nécessite des fichiers `.service` dans le dossier `/etc/systemd/system/` pour tous les services qu'il peut gérer. Ainsi, il faut créer ces fichiers et y définir les paramètres voulus pour chaques composants.

Après s'être dirigé dans le bon dossier via `cd /etc/systemd/system/`, il faut faire `sudo nano nom-du-service.service`, où _nom-du-service.service_ est un des fichiers ci-dessous. Puis il faut copier le contenu respectif et répéter le tout pour chacun des services requis :

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
ExecStart=/home/pi/MOvITPlus/MOvIT-Detect-Backend/node_modules/node-red/bin/node-red-pi -u /home/pi/MOvITPlus/MOvIT-Detect-Backend --max-old-space-size=256

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
WantedBy=multi-user.target```
```

- **movit_detect_python.service**
```bash
[Unit]
Description=-------- MOVIT+ detect software (python)
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
User=pi
Group=pi
Environment=PYTHONPATH=/home/pi/MOvITPlus/MOvIT-Detect/python
ExecStart=/home/pi/MOvITPlus/MOvIT-Detect/python/venv/bin/python3 /home/pi/MOvITPlus/MOvIT-Detect/python/launcher.py 

[Install]
WantedBy=multi-user.target
```

## 5.2. Utilisation des services
Afin que les services soit lancés au démarrage, les commandes suivantes sont essentielles :
```bash
sudo systemctl enable movit_backend.service
sudo systemctl enable movit_frontend.service
sudo systemctl enable movit_detect_python.service
```

> Il est recommandé de **ne pas activer ces services avant la fin de l'installation du projet**
> Voir la section [Installation de MOvIT +](#4-installation-de-movit)

Pour pouvoir utiliser et tester les services immédiatement sans redémarrer le système, il sera nécessaire d'effectuer la commande suivante :
```bash
sudo systemctl daemon-reload
```

Il est possible de connaître l'état, lancer et arrêter les services avec les commandes suivantes :
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

# 6. Optimisation du temps de démarrage
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

# 7. Mises à jour du système

## Mise à jour du projet manuellement
Une des parties de la mise est jour est simplement l'utilisation de la commande `git pull` dans le dossier parent. En plus du `git pull` habituel, il peut être également nécessaire de mettre à jour les sous-répertoires :
```bash
git pull
git submodule update --init --recursive
```
- Charge les versions des sous-répertoires liées (tag de versions des sous-répertoires)
- Met à jour les scripts et les autres fichiers contenus par le répertoire parent
> Les services devraient être arrêtés avant de procéder ainsi.
___

<br>
<br>
