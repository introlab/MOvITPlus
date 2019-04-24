# Démarrage des programmes à l'aide de systemd
Pour démarrer certains programmes, il est utile de créer un service qui va permettre de lancer un programme au démarrage et nous permettre de le contrôler et de le surveiller. Pour commencer il faut un nom a notre service, je vais utiliser ici `exemple`. Il faut tout d'abord créer un fichier avec le nom du service correspondant soit `/etc/systemd/system/exemple.service`. Dans ce fichier il faut écrire les lignes suivantes:

```bash
[Unit]
Description=exemple demo service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=pi
ExecStart=/bin/bash commande/a/execute.sh

[Install]
WantedBy=multi-user.target
```
Il faudra changer la `Description` du service ainsi que le lien du script a exécuté `ExecStart`. Le lien doit être absolu, il est donc important d'avoir le lien complet du fichier à exécuter.

## Démarrage du service
Pour démarrer le service, il suffit d'exécuter la commande suivante:
```bash
sudo systemctl start exemple
```
## Arrêt du service
Pour arrêter le service, il suffit d'exécuter la commande suivante:
```bash
sudo systemctl stop exemple
```
## Status du service
Pour connaitre l'état du service, il suffit d'exécuter la commande suivante:
```bash
sudo systemctl status exemple
```
## Activer le démarrage au boot du service
Pour que le service soit lancé au démarrage il suffit d'exécuté:
```bash
sudo systemctl enable exemple
```
## Désactiver le démarrage au boot du service
Pour que le service ne soit plus lancé au démarrage il suffit d'exécuté:
```bash
sudo systemctl disable exemple
```
