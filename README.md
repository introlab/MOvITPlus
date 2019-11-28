

# MOvIT Plus
Ce répertoire contient tous les éléments nécessaires pour faire fonctionner un système MOvIt+. L'utilisation d'une **image préconfiguré** et des **scripts** de mise à jour est recommendée [**[installation rapide](#1-installation-rapide "Section de ce document")**], mais il possible de suivre les instructions et la documentation pour préparer un système à partir de rien [**[installation complète](#installation-compl%c3%a8te "Section de ce document")**].

## 1. Installation rapide
### 1.2. Flashage
L'image préconfigurée doit être flashée à l'aide d'un logiciel comme [Balena Etcher](https://www.balena.io/etcher/ "Site officiel de Balena Etcher") sur une carte SD.
**AJOUTER DÉTAILS DISPONIBILITÉ DE L'IMAGE**
Avec ce logiciel, il suffit de brancher la carte SD avec un adapteur approprié puis, une fois le logiciel lancé, il faut sélectionner l'image téléchargée. Il faut ensuite vérifier que la carte SD détectée par le logiciel est la bonne puis appuyer sur le bouton pour lancer le flashage. Une fois terminé, il peut être nécessaire de sortir et de réinserrer la carte afin de faire une dernière modification telle que décrite ci-dessous.

### 1.3. Configuration sans fil
**Il est recommandé de placer un fichier nommé `wpa_supplicant.conf` dans la partition `boot`** d'une carte SD nouvellement flashé. Celui-ci doit être remplit selon la structure ci-bas avec les informations pour se connecter au réseau wifi choisi. Le système l'utilisera afin de permettre une connection au wifi spécifié dès les premiers démarrages.
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

> L'initialisation automatisé **nécessite une connection à internet** pour fonctionner([spécification de cette connection internet]()). Si les scripts ne fonctionnent pas ([déboggage]()) , il peut être nécessaire de se connecter en SSH et de relancer le script lorsque la configuration réseau est réparée (voir [documentation de configuration wifi](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md#21-connection-%c3%a0-un-r%c3%a9seau-wi-fi)). L'[étape 1.3](#13-configuration-sans-fil) peut également être répété si une erreur s'est glissée dans le fichier `wpa_supplicant.conf`.

### 1.5. Vérification
À ce point-ci, le système devrait être correctement configuré. Pour tester s'il est fonctionnel, il suffit de se connecter sur le point d'accès de l'appareil (Movit-******), puis d'accèder à l'addresse `movit.plus` dans un navigateur. Lorsqu'une page apparait, il suffit de se connecter avec les identifiants voulu. Voir la documentation de la partie frontend pour plus de détails.

___
<br>
<br>



## 2. Explications
> Documentation incomplète et non à jour.
#### Script de configuration
**`MovitPlusSetup.sh`**
Ce script vise à simplifier le paramètrage d'une image _Rasbian Buster Lite_ dans le but de générer une image préconfiguration. Cependant, le script n'a pas été testé complètement et représente d'avantage une piste sur la façon d'y arriver qu'un moyen certain. La dernière partie du script permet d'annuler en partie les effets de l'essaie du script `firstBootSetup.sh`.
> Il est recommendé d'exécuter ce script prudemment et de vérifier chaque étape.


#### Script d'initialisation de système
**`firstBootSetup.sh`**
Lors de son premier démarrage, le Raspberry Pi avec la carte nouvellement flashé avec l'image préconfigurée effectue la configuration de son _hostname_ et de quelques autres paramètres spécifiques à chaque appareil.
Le script procède ensuite à l'installation de chacune des composantes du projet dans leur version stable la plus à jour. Celles-ci correspondent aux tags de version référencés dans ce répertoire parent. [Ces tags peuvent être mis à jour](#mise-%c3%a0-jour-des-sous-r%c3%a9pertoires "Mise à jour des sous-répertoires"). La configuration se termine l'écriture du temps du système sur le RTC _(Real Time Clock)_ puis avec de multiples lancements du script de mise à jour (`updateProject.sh`) avec l'argument `--sys-config` et `--init`.


Ce script doit demeurer sous `/home/pi` et la façon pour l'exécuter est donc `/home/pi/./firstBootSetup.sh`

Ce script peut également être utilisé pour mettre à jour tous les fichiers en lien avec l'addresse MAC physique d'un appareil. Par exemple, si la carte SD est installée dans un autre RaspberryPi, les références à l'addresse MAC doivent être changée pour correspondre à cette nouvelle addresse MAC. Pour ce faire, il faut appeler le script avec l'argument `--nogit` pour éviter une nouvelle tentative d'installation des répertoires avec _Git_.

Aussi, le script peut être lancé avec l'argument `--restore` afin de restaurer l'appel au démarrage de ce script au prochain démarrage. La commande `--remove` fait l'inverse.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/firstBootSetup.log`

###****# Script de mise à jour
**`updateProject.sh`**
Le scipt de mise à jour permet la mise à jour des fichiers nécessaires au projet, la mise à jour de la configuration du RaspberryPi, l'initialisation d'une nouvelle instance du projet et la configuration du RTC _(Real Time Clock)_. Voici les options qui peuvent être entrées en argument :
   - `--sys-config` : Mise à jour de la configuration du système (ex: services de démarrage)
   - `--init-project` : Initialisation du projet (ex: nouvelle base de donnée)
   - `--git-update` : mise à jour des répertoires du projet avec Git

Additionnelement, l'ajout de l'argument `--console-log` redirige la sortie de l'éxecution à la console.

> ATTENTION : Il est recommandé d'appeler `--git-update` à l'aide de cette commande :
> ```bash
> curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
> ```
> Celle-ci permet d'éviter les conflits lorsque Git fait son travail.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/updateProject.log.log`

### 1.5 Initialisation du projet
Pour initialiser le projet, il faut exécuter la commande suivante :
```bash
sudo /home/pi/MOvITPlus/./updateProject.sh --init-project --console-log
```
Le script s'occupe alors d'installer le backend, d'initialiser la base de données, d'installer le frontend puis finalement de compiler les librairies et le code d'acquisition. Il termine en activant tous les services et en les démarrant.
___




voir `firstBootScript.log` et `updateProject.log.log` dans le répertoire ` /home/pi/`)
___

<br>
<br>




## Installation manuelle
### Documentation et installation manuelle
Un nouveau système peut être installé manuellement en suivant la documentation sur la [configuration d'un nouveau système](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md "Configuration du système"), puis la documentation de chacune des parties du projet ([MOvIT-Detect](), [MOvIT-Detect-Backend](), [MOvIT-Detect-Frontend]()).

### Génération d'image
Il également possible d'utiliser le script `MovitPlusSetup.sh`. Ce dernier effectue essentiellement toutes les étapes nécessaires générer l'image préconfiguré en partant d'un image de Rasbian Lite. Cela permettra donc d'utiliser les scripts mentionnés plus haut pour terminer l'installation du projet par la suite.

> **Attention :** ce script n'a pas été testé complètement et certaines erreurs plus ou moins importantes pourraient survenir. L'utiliser à vos risque. 


## MOvIT-Detect
Contiens tout le code nécessaire pour communiquer avec des capteurs via I2C et SPI à partir d'un Raspberry Pi Zero W et des circuits imprimés faits sur mesure. La communication avec le backend est faites via MQTT. Ce code fonctionne sur Raspberry Pi Zero W, ou tout autre processeur ARM basé sur le processeur BroadCom bcm2835.

## MOvIT-Detect-Backend
C'est le backend du système, il a été conçu en node-red, ce qui permet d'effectuer des modifications rapidement et simplement. Il reçoit les données via MQTT du code d'acquisition et enregistre les données dans une base de données MongoDB 2 localement. Les donnes sont alors traitées et peuvent être affichées à l'aide de requête GET et POST, également utilisé par le frontend pour afficher l'information.

## MOvIT-Detect-Frontend
C'est le frontend du système, utilisé par le clinicien et le patient. Ce code utilise React et Redux afin de créer une application web fluide. Les données sont affichées sous forme de graphique facile à lire et interprétées. 

## MOvIT-Hardware
Contiens tous les fichiers de fabrication pour concevoir, ce qui permet de recréer le système en entier.





____





____
____
____
____


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
- Pour observer et suivre en temps réel le déroulement du des scripts qui écrit dans un fichier _.log_, la commande `tail -fn 50 #nom_du_fichier.log` affichera les 50 dernières lignes ainsi que les lignes qui se rajouteront à mesure.
- L'utilisation de l'argument --console-log pour le script `updateProject.sh` montrera le progrès de NPM et Yarn lors de l'exécution de ces étapes.
    > Attention, les logs ne sont pas sauvegardés lors de l'utilisation de cet argument.
- Pour trouver le nom du Raspberry Pi pour, par exemple, se connecter en SSH, il suffit de regarder le nom du point d'accès créé par le Pi. Si celui-ci n'a pas encore réussi à terminer sa configuration ou qu'un erreur est survenu pendant celle-ci, alors le hostname du Pi sera `Movit-NOCONF`.







<br>
<br>
<br>
<br>
<br>