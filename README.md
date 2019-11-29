

# MOvIT Plus
Ce répertoire contient tous les éléments nécessaires pour faire fonctionner un système MOvIt+. L'utilisation d'une **image préconfiguré** et des **scripts** de mise à jour est recommendée [**[installation rapide](#1-proc%c3%a9dure-dinstallation-rapide "Section de ce document")**], mais il possible de suivre les instructions et la documentation pour préparer un système à partir d'un image _Rasbian Buster Lite_ [**[installation complète](#proc%c3%a9dure-dinstallation-manuelle "Section de ce document")**].

# Procédures d'installation
## 1. Installation rapide

L'image préconfigurée est disponible sous l'onglet _"Releases"_ de GitHub.
### 1.2. Flashage
Elle doit être flashée à l'aide d'un logiciel comme [Balena Etcher](https://www.balena.io/etcher/ "Site officiel de Balena Etcher") sur une carte SD. Avec ce logiciel, il suffit de **brancher la carte** SD avec un adapteur approprié, de **sélectionner l'image** téléchargée, puis de **lancer le flashage**. Une fois terminé, il peut être nécessaire de sortir et de réinserrer la carte afin de faire une dernière modification telle que décrite ci-dessous.

### 1.3. Configuration réseau
Il est recommandé de **placer un fichier nommé `wpa_supplicant.conf` dans la partition `boot`** d'une carte SD nouvellement flashé. Celui-ci doit être remplit selon la structure ci-bas avec les informations pour se connecter au réseau wifi choisi. Le système l'utilisera afin de permettre une connection au réseau wifi spécifié dès les premiers démarrages.
**`wpa_supplicant.conf`** :
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

### 1.4. Initialisation automatisé
Des scripts s'activant automatiquement permettent d'initialiser un nouvel appareil. Aucune action n'est requise outre que d'**insérer la carte SD** et de **brancher l'appareil**. L'exécution de ces scripts peut prendre quelques minutes.

> Attention : **l'appareil ne doit pas être débranché** pendant son initialisation!

> L'initialisation automatisé **nécessite une connection à internet** pour fonctionner([spécification de cette connection internet]()). L'[étape 1.3](#13-configuration-sans-fil) peut être répété si une erreur s'est glissée dans le fichier `wpa_supplicant.conf`.
> Si les scripts ne fonctionnent pas, il peut être nécessaire de se connecter en SSH et de relancer le script lorsque la configuration réseau est réparée (voir [documentation de configuration wifi](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md#21-connection-%c3%a0-un-r%c3%a9seau-wi-fi)).  Pour plus de détails, voir la section [déboggage]().

### 1.5. Installation du projet
Avec l'état actuel du projet, il est nécessaire de se connecter à l'appareil en SSH (ou avec un clavier, un écran et les adapteurs appropriés) pour activer manuellement un script d'installation. La connection se fait donc, à partir d'un autre ordinateur connecté au même réseau, avec la commande `ssh pi@hostname`, où hostname est le nom de l'appareil.

> Pour trouver le nom du Raspberry Pi, il suffit de regarder le nom du point d'accès créé par le Pi. Autrement, si celui-ci n'a pas encore réussi à terminer sa configuration ou qu'un erreur est survenu pendant celle-ci, alors le hostname du Pi sera `Movit-NOCONF`.

L'utilisateur est `pi` et le mot de passe `movitdev` par défaut.
Une fois connecté, pour initialiser le projet, il faut exécuter la commande suivante :
```bash
sudo /home/pi/MOvITPlus/./updateProject.sh --init-project
```
L'exécution de ce script peut prendre environ **30 minutes** dans l'état actuel du projet. Il est possible de suivre le résultat de l'exécution du script en temps réel avec une commande comme `tail -fn 50 #nom_du_fichier.log`, qui affichera les 50 dernières lignes ainsi que celles qui se rajouteront à mesure.


> L'ajout de l'argument --console-log pour le script `updateProject.sh` montrera le progrès de NPM et Yarn lors de l'exécution de ces étapes directement dans la console. **Attention :** les logs ne sont pas sauvegardés lors de l'utilisation de cet argument.

### 1.6. Vérification
À ce point-ci, le système devrait être correctement configuré. Pour tester s'il est fonctionnel, il suffit de se connecter sur le point d'accès de l'appareil (Movit-******), puis d'accèder à l'addresse `movit.plus` dans un navigateur. Lorsqu'une page apparait, il suffit de se connecter avec les identifiants voulu. Voir la documentation de la partie frontend ou la documentation d'utilisation pour plus de détails.

____

## 2. Installation manuelle
Un nouveau système peut être installé manuellement en suivant la documentation sur la [configuration d'un nouveau système](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md "Configuration du système"), puis la documentation de chacune des parties du projet ([MOvIT-Detect](), [MOvIT-Detect-Backend](), [MOvIT-Detect-Frontend]()).
Il également possible d'utiliser le script `MovitPlusSetup.sh`. Ce dernier effectue essentiellement toutes les étapes nécessaires générer l'image préconfiguré en partant d'un image de Rasbian Lite. Voir les explications sur le [script de configuration](#script-de-configuration).

### Génération d'images
#### Préparation du système
Afin d'avoir une image fonctionnelle et pratique, plusieurs étapes s'imposent. Bien évidemment, la majorité de la configuration décrite dans la documentation doit être complétée, mais il faut également retirer la configuration dans `wpa_supplicant.conf`, retirer `70-persistent-net.rules`, retirer le dossier `/home/pi/MOvITPlus`, retirer les fichiers logs sous `/home/pi`, mettre à jour `/etc/hostname`, `/etc/hosts` et `/etc/hostapd/hostapd.conf` avec le _hostname_ Movit-NOCONF puis finalement activer le service `movit_setup.service`.
Toutes ces étapes peuvent être réalisé avec le [script de configuration](#script-de-configuration) et son option `--prepare`.

#### Création d'une image
Lorsque le système est proprement configuré, sur un autre ordinateur tournant préférablement sous linux, il faut suivre les [instructions disponibles sur ce site](https://medium.com/platformer-blog/creating-a-custom-raspbian-os-image-for-production-3fcb43ff3630).

Pour rendre le processus plus rapide dans le cas où plusieurs images doivent être générée et testée, le script `CreateImage.sh` peut être modifié accordément à votre installation.

____
<br>
<br>

# Documentation des parties du projet
## MOvIT-Detect
Contiens tout le code nécessaire pour communiquer avec des capteurs via I2C et SPI à partir d'un Raspberry Pi Zero W et des circuits imprimés faits sur mesure. La communication avec le backend est faites via MQTT. Ce code fonctionne sur Raspberry Pi Zero W, ou tout autre processeur ARM basé sur le processeur BroadCom bcm2835.

## MOvIT-Detect-Backend
C'est le backend du système, il a été conçu en node-red, ce qui permet d'effectuer des modifications rapidement et simplement. Il reçoit les données via MQTT du code d'acquisition et enregistre les données dans une base de données MongoDB 2 localement. Les donnes sont alors traitées et peuvent être affichées à l'aide de requête GET et POST, également utilisé par le frontend pour afficher l'information.

## MOvIT-Detect-Frontend
C'est le frontend du système, utilisé par le clinicien et le patient. Ce code utilise React et Redux afin de créer une application web fluide. Les données sont affichées sous forme de graphique facile à lire et interprétées. 

## MOvIT-Hardware
Contiens tous les fichiers de fabrication pour concevoir, ce qui permet de recréer le système en entier.

____

<br>
<br>

# Documentation des scripts
#### Service d'initialisation
Un service nommé `movit_setup.service` s'occupe de lancer le script d'initialisation du système `firstBootSetup.sh` au bon moment dans la sécance de démarrage. Celui-ci se trouve dans `/etc/systemd/system/` et permet notamment de redémarrer le système si le script s'exécute avec succès. Il est activé par défaut dans les images préconfigurées afin de s'exécuter au premier démarrage et il se désactive uniquement si le script termine sa tâche avec succès.

#### Script d'initialisation de système
**`firstBootSetup.sh`**
Le script effectue la configuration de son _hostname_ et de quelques autres paramètres spécifiques à chaque appareil.
Le script procède ensuite à l'installation de chacune des composantes du projet dans leur version stable la plus à jour. Celles-ci correspondent aux tags de version référencés dans ce répertoire parent. [Ces tags peuvent être mis à jour](#mise-%c3%a0-jour-des-sous-r%c3%a9pertoires "Mise à jour des sous-répertoires"). La configuration se termine par l'écriture du temps système sur le RTC _(Real Time Clock)_ puis avec un lancement du script de mise à jour (`updateProject.sh`) avec l'argument `--sys-config`.

Ce script doit demeurer sous `/home/pi/` à cause du service qui le lance au démarrage et la façon de l'exécuter manuellement est donc `/home/pi/./firstBootSetup.sh`. Voici les options qui peuvent être entrées en argument :
   - **`--restore`** : Restauration de l'appel au démarrage de ce script pour le prochain démarrage
   - **`--remove`** : Suppression de l'appel au démarrage de ce script
   - **`--no-git`** : Empêche l'exécution des étapes liées au téléchargement du projet avec Git
   - _`--fromService`_ : Différencie les exécutions manuelles des lancements au démarrage dans les logs. Ne pas l'utiliser manuellement.

Additionnelement, l'ajout de l'argument **`--console-log`** redirige la sortie de l'éxecution à la console.

Ce script peut également être utilisé pour mettre à jour tous les fichiers en lien avec l'addresse MAC physique d'un appareil. Par exemple, si la carte SD est installée dans un autre RaspberryPi, les références à l'addresse MAC doivent être changée pour correspondre à cette nouvelle addresse. Pour ce faire, il faut appeler le script avec l'argument `--nogit` pour éviter une nouvelle tentative d'installation des répertoires avec _Git_.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/firstBootSetup.log`

#### Script de mise à jour
**`updateProject.sh`**
Le scipt de mise à jour permet la mise à jour des fichiers nécessaires au projet, la mise à jour de la configuration du RaspberryPi et surtout l'initialisation d'une nouvelle instance du projet. Voici les options qui peuvent être entrées en argument :
   - **`--sys-config`** : Mise à jour de la configuration du système (ex: services de démarrage)
   - **`--init-project`** : Initialisation du projet (ex: nouvelle base de donnée et installation avec Yarn et NPM)
   - **`--git-update`** : Mise à jour des répertoires du projet avec Git

Additionnellement, l'ajout de l'argument **`--console-log`** redirige la sortie de l'éxecution à la console.

Avec **`--init-project`**, le script s'occupe d'installer le backend, d'initialiser la base de données, d'installer le frontend puis finalement de compiler les librairies et le code d'acquisition. Il termine en activant tous les services pour le prochain démarrage.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/updateProject.log.log`

#### Script de configuration
**`MovitPlusSetup.sh`**
Ce script vise à simplifier le paramètrage d'une image _Rasbian Buster Lite_ dans le but de générer une image préconfigurée. Cependant, le script n'a pas été testé complètement et représente d'avantage une piste sur la façon d'y arriver qu'un moyen certain. La dernière partie du script permet d'annuler en partie les effets de l'essaie du script `firstBootSetup.sh`. Voici les options qui peuvent être entrées en argument :
   - **`--prepare`** : Nettoyage et préparation de l'appareil en vue de la création d'une image
   - **`--fresh-rasbian-image`** : Exécution des différentes parties du script à la suite avec une confirmation entre chaque étape.
> **Attention :** Ce script n'a pas été testé complètement et certaines erreurs plus ou moins importantes pourraient survenir. Il est recommendé d'exécuter ce script prudemment et de vérifier chaque étape.

#### Script de création d'image
**`CreateImage.sh`**
Ce script vise à faciliter la génération d'images selon [cette méthode](https://medium.com/platformer-blog/creating-a-custom-raspbian-os-image-for-production-3fcb43ff3630) une fois qu'une carte SD entièrement configurée est insérée. Il incorpore le clonage de la carte, l'excution du [script piShrink.sh](https://github.com/Drewsif/PiShrink) ainsi que le lancement de [Balena Etcher - CLI](https://github.com/balena-io/balena-cli).

___

<br>
<br>

# Autre documentation
## Déboggage
> À venir

voir `firstBootScript.log` et `updateProject.log.log` dans le répertoire ` /home/pi/`

## Git
### Installation de MOvIt Plus
L'installation de MOvIt requiert un `git clone` habituel mais comporte quelques subtilitées avec les sous-modules.

#### Installation initiale
Ce répertoire devrait être installé sous `home/pi/`. La commande suivante installe tous les dossiers nécessaires.
```bash
git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules
```

#### Mise à jour du répertoire parent
   - Charge les versions des sous-répertoires liées (tag de versions des sous-répertoires)
   - Met à jour les scripts et les autres fichiers contenu par le répertoire parent
```bash
git pull
git submodule update --init --recursive
```

#### Mise à jour des sous-répertoires
Cette commande permet de mettre à jour les sous-répertoires à leur version la plus récente sur leur `origin/master` respectifs. Elle change donc le tag de versions des sous-répertoires.
```bash
git submodule update --remote
```
Il est ensuite possible de mettre à jour le répertoire parent avec ces dernières versions des sous-répertoires. Pour voir ce qui a été modifié, `git status` retourne la liste des fichiers et des tags de répertoires qui ont été modifiés. En faisant `git add [les dossiers à mettre à jour]` puis les commandes habituelles `git commit` et `git push`, il est possible de rendre ces changements officiels. Le prochain clone avec les sous-modules ira ainsi chercher les versions les plus à jour du répertoire.

> [Documentation sur les sous-modules GitHub](https://git-scm.com/book/en/v2/Git-Tools-Submodules "GitHub Submodules")


### Astuces
- Pour exécuter uniquement certaines partie d'un script, il est plus rapide de faire un `if false; then` en début, et `fi` en fin du segment qui doit être ignoré que de commenter toutes les lignes.

<br>
<br>
<br>
<br>
<br>