#### Création d'une image
>Lorsque le système est proprement configuré, sur un autre ordinateur tournant préférablement sous Linux, il faut suivre les [instructions disponibles sur ce site](https://medium.com/platformer-blog/creating-a-custom-raspbian-os-image-for-production-3fcb43ff3630). Pour rendre le processus plus rapide dans le cas où plusieurs images doivent être générée et testée, le script `CreateImage.sh` peut être modifié en fonction de votre installation.

## 1. Génération d'images
#### Préparation du système
Afin d'avoir une image fonctionnelle et pratique, plusieurs étapes s'imposent. Bien évidemment, la majorité de la configuration décrite dans la documentation doit être complétée, mais il faut également retirer la configuration dans `wpa_supplicant.conf`, retirer `70-persistent-net.rules`, retirer les fichiers logs sous `/home/pi`, mettre à jour `/etc/hostname`, `/etc/hosts` et `/etc/hostapd/hostapd.conf` avec le _hostname_ Movit-NOCONF.
