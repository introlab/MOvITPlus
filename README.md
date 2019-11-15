

# MOvIT Plus
Ce répertoire contient tous les éléments nécessaires pour faire fonctionner un système MOvIt+. L'utilisation d'une **image préconfiguré** et des **scripts** de mise à jour est recommendée [**[installation simplifiée](#installation-simplifi%c3%a9e "Section de ce document")**], mais il possible de suivre les instructions et la documentation pour préparer un système à partir de rien [**[installation complète](#installation-compl%c3%a8te "Section de ce document")**].

## 1. Installation simplifiée
### 1.2. Image préconfigurée
Autrement, l'image préconfiguré doit être flashé à l'aide d'un logiciel comme [Balena Etcher](https://www.balena.io/etcher/ "Site officiel de Balena Etcher") sur une carte SD.
**DISPONIBILITÉ DE L'IMAGE**
### 1.3. Configuration sans fil
Un fichier nommé `wpa_supplicant.conf` remplit, selon la structure ci-bas, avec les informations pour se connecter au réseau wifi choisi peut être placé dans la partition boot d'une carte SD nouvellement flashé. Le système l'utilisera afin de permettre une connection au wifi spécifié dès le premier démarrage. 
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
### 1.4. Initialisation automatisé
L'initialisation automatisé d'une nouvelle machine nécessite une connection à internet pour fonctionner. Si les scripts ne fonctionnent pas (voir les `.logs` dans `/home/pi`), il peut être nécessaire de se connecter en SSH et de relancer le script lorsque la configuration est réparée (voir [documentation de configuration wifi](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md#21-connection-%c3%a0-un-r%c3%a9seau-wi-fi))

#### Script de configuration
**`firstBootSetup.sh`**
Lors de son premier démarrage, le Raspberry Pi avec la carte nouvellement flashé effectue la configuration de son _hostname_ et de quelques autres paramètres spécifiques à chaque appareil.
Le script procède ensuite à l'installation de chacune des composantes du projet dans leur version stable la plus à jour. Celles-ci correspondent aux tags de version référencés dans ce répertoire parent. [Ces tags peuvent être mis à jour](#mise-%c3%a0-jour-des-sous-r%c3%a9pertoires "Mise à jour des sous-répertoires"). La configuration se termine avec de multiples lancements du script de mise à jour (`updateProject.sh`) avec l'argument `--rtc-time`, `--sys-config` et `--init`.
> Ce script enregistre la sortie de ses exécutions dans `/home/pi/firstBootSetup.log`

#### Script de mise à jour
**`updateProject.sh`**
Le scipt de mise à jour permet la mise à jour des fichiers nécessaires au projet, la mise à jour de la configuration du RaspberryPi, l'initialisation d'une nouvelle instance du projet et la configuration du RTC _(Real Time Clock)_. Voici les options qui peuvent être entrées en argument :
   - `--sys-config` : Mise à jour de la configuration du système (ex: services de démarrage)
   - `--init-project` : Initialisation du projet (ex: nouvelle base de donnée)
   - `--rtc-time` : Écrit le temps du système sur le RTC _(Real Time Clock)_
   - `--git-update` : mise à jour des répertoires du projet avec Git

Additionnelement, l'ajout de l'argument `--console-log` redirige la sortie de l'éxecution à la console.

> ATTENTION : `--git-update` ne doit pas être appelé directement mais à l'aide de
> ```bash
> curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
> ```
> Cette commande permet d'éviter les conflits lorsque Git fait son travail.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/updateProject.log.log`





<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Installation complète
Pour ce faire, [la documentation sur la configuration d'un nouveau système](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md "Configuration du système") est essentielle.
### Installation de MOvIt Plus
L'installation de MOvIt requiert un `git clone` habituel mais comporte quelques subtilitées avec les sous-modules.

#### Installation initiale
Ce répertoire devrait être installé sous `home/pi/`. La commande suivante installe tous les dossiers nécessaires.
```bash
git clone https://github.com/introlab/MOvITPlus.git --recurse-submodules
```

#### Mise à jour du répertoire parent
   - Met à jour les liens vers les bonnes versions des sous-répertoires
   - Charge les versions des sous-répertoires liées
   - Met à jour les scripts et les autres fichiers contenu par le répertoire parent
```bash
git pull
git submodule update --init --recursive
```

#### Mise à jour des sous-répertoires
Cette commande permet de mettre à jour les sous-répertoires à leur version la plus récente sur leur `origin/master` respectifs
```bash
git submodule update --remote
```
Il est ensuite possible de mettre à jour le répertoire parent avec ces dernières versions des sous-répertoires en faisant `git add [les dossiers à mettre à jour]` puis les commandes habituelles `git commit` et `git push`. Le prochain clone avec les sous-modules ira ainsi chercher les versions les plus à jour du répertoire.

> [Documentation sur les sous-modules GitHub](https://git-scm.com/book/en/v2/Git-Tools-Submodules "GitHub Submodules")

## MOvIT-Detect
Contiens tout le code nécessaire pour communiquer avec des capteurs via I2C et SPI à partir d'un Raspberry Pi Zero W et des circuits imprimés faits sur mesure. La communication avec le backend est faites via MQTT. Ce code fonctionne sur Raspberry Pi Zero W, ou tout autre processeur ARM basé sur le processeur BroadCom bcm2835.

## MOvIT-Detect-Backend
C'est le backend du système, il a été conçu en node-red, ce qui permet d'effectuer des modifications rapidement et simplement. Il reçoit les données via MQTT du code d'acquisition et enregistre les données dans une base de données MongoDB 2 localement. Les donnes sont alors traitées et peuvent être affichées à l'aide de requête GET et POST, également utilisé par le frontend pour afficher l'information.

## MOvIT-Detect-Frontend
C'est le frontend du système, utilisé par le clinicien et le patient. Ce code utilise React et Redux afin de créer une application web fluide. Les données sont affichées sous forme de graphique facile à lire et interprétées. 

## MOvIT-Hardware
Contiens tous les fichiers de fabrication pour concevoir, ce qui permet de recréer le système en entier.
