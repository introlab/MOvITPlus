# Documentation des scripts
### Service d'initialisation
Un service nommé `movit_setup.service` s'occupe de lancer le script d'initialisation du système `firstBootSetup.sh` au bon moment dans la sécance de démarrage. Celui-ci se trouve dans `/etc/systemd/system/` et permet notamment de redémarrer le système si le script s'exécute avec succès. Il est activé par défaut dans les images préconfigurées afin de s'exécuter au premier démarrage et il se désactive uniquement si le script termine sa tâche avec succès.

### Script d'initialisation au démarrage
**`firstBootSetup.sh`**
Le script effectue la configuration de son _hostname_ et de quelques autres paramètres spécifiques à chaque appareil.
Le script procède ensuite à l'installation de chacune des composantes du projet dans leur version stable la plus à jour. Celles-ci correspondent aux tags de version référencés dans ce répertoire parent. [Ces tags peuvent être mis à jour](#mise-%c3%a0-jour-des-sous-r%c3%a9pertoires "Mise à jour des sous-répertoires"). La configuration se termine par l'écriture du temps système sur le RTC _(Real Time Clock)_ puis avec un lancement du script de mise à jour (`updateProject.sh`) avec l'argument `--sys-config`.

Ce script doit demeurer sous `/home/pi/` à cause du service qui le lance au démarrage et la façon de l'exécuter manuellement est donc `/home/pi/./firstBootSetup.sh`. Voici les options qui peuvent être entrées en argument :
   - **`--restore`** : Restauration de l'appel au démarrage de ce script pour le prochain démarrage
   - **`--remove`** : Suppression de l'appel au démarrage de ce script
   - **`--no-git`** : Empêche l'exécution des étapes liées au téléchargement du projet avec Git
   - _`--fromService`_ : Différencie les exécutions manuelles des lancements au démarrage dans les logs. Ne pas l'utiliser manuellement.

Additionnelement, l'ajout de l'argument **`--console-log`** redirige la sortie de l'exécution à la console. Les logs ne sont pas sauvegardés lors de l'utilisation de cet argument.

Ce script peut également être utilisé pour mettre à jour tous les fichiers en lien avec l'adresse MAC physique d'un appareil. Par exemple, si la carte SD est installée dans un autre RaspberryPi, les références à l'adresse MAC doivent être changées pour correspondre à cette nouvelle adresse. Pour se faire, il faut appeler le script (idéalement avec l'argument `--nogit` pour éviter une nouvelle tentative d'installation des répertoires avec _Git_). Il est aussi possible de simplement réactiver le service avant de changer la carte SD d'appareil.

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/firstBootSetup.log`


### Script de mise à jour
**`updateProject.sh`**
Le script de mise à jour permet la mise à jour des fichiers nécessaires au projet, la mise à jour de la configuration du RaspberryPi et surtout l'initialisation d'une nouvelle instance du projet. Voici les options qui peuvent être entrées en argument :
   - **`--init-project`** : Initialisation du projet (ex: nouvelle base de donnée et installation avec Yarn et NPM)
   - **`--sys-config`** : Mise à jour de la configuration du système (ex: services de démarrage)
   - **`--git-update`** : Mise à jour des répertoires du projet avec Git (devrait être exécuté avec `curl`, voir plus bas)

Additionnellement, l'ajout de l'argument **`--console-log`** redirige la sortie de l'exécution à la console. Les logs ne sont pas sauvegardés lors de l'utilisation de cet argument.

Avec **`--init-project`**, le script s'occupe d'installer le backend, d'initialiser la base de données, d'installer le frontend puis finalement de compiler le code d'acquisition. Il termine en activant tous les services pour le prochain démarrage.
L'exécution de ce script peut prendre environ **30 minutes** dans l'état actuel du projet.
> Pour voir davantage de détails sur la progression de Yarn et NPM directement dans la console, il est possible d'ajouter l'argument `--console-log`.

Pour l'argument **`--git-update`**, le script devrait être exécuté avec la commande suivante de façon à aller chercher la dernière version du script de mise à jour.
```bash
curl -s https://raw.githubusercontent.com/introlab/MOvITPlus/master/updateProject.sh | sudo bash -s - --git-update
```

> Ce script enregistre la sortie de ses exécutions dans `/home/pi/updateProject.log.log`

### Script de configuration
**`MovitPlusSetup.sh`**
Ce script vise à simplifier le paramétrage d'une image _Rasbian Buster Lite_ dans le but de générer une image préconfigurée. Cependant, le script n'a pas été testé complètement et représente davantage une piste sur la façon d'y arriver qu'un moyen certain. La dernière partie du script permet d'annuler en partie les effets de l'essai du script `firstBootSetup.sh`. Voici les options qui peuvent être entrées en argument :
   - **`--fresh-rasbian-image`** : Exécution des différentes parties du script à la suite avec une confirmation entre chaque étape.
   - **`--prepare`** : Nettoyage et préparation de l'appareil en vue de la création d'une image
> **Attention :** Ce script n'a pas été testé complètement et certaines erreurs plus ou moins importantes pourraient survenir. Il est recommendé d'exécuter ce script prudemment et de vérifier chaque étape.

### Script de création d'images
**`CreateImage.sh`**
Ce script vise à faciliter la génération d'images selon [cette méthode](https://medium.com/platformer-blog/creating-a-custom-raspbian-os-image-for-production-3fcb43ff3630) une fois qu'une carte SD entièrement configurée est insérée. Il incorpore le clonage de la carte, l'exécution du [script piShrink.sh](https://github.com/Drewsif/PiShrink) ainsi que le lancement de la [version CLI de Balena Etcher](https://github.com/balena-io/balena-cli). Il doit être adapté aux cas d'utilisation particuliers à chaque fois au besoin.

___

<br>
<br>

# Déboggage
Si des problèmes surviennent lors de l'exécution des scripts, la façon la plus facile de règler les problèmes est d'utiliser l'information contenue dans les fichiers _.log_. Les deux fichiers qui devraient être générés sont `firstBootScript.log` et `updateProject.log.log` dans le répertoire ` /home/pi/`.


### Problèmes de réseau
Les scripts quitterons rapidement avec un message d'erreur semblable si un problème est detecté avec la configuration réseau :
```bash
### The network is down, cannot run first boot setup
### Please fix internet connection and ...
```
Cette connection est critique au fonctionnement du système et à son initilisation. Vérifier le contenu de `/etc/wpa _supplicant/wpa _supplicant.conf` est donc une étape essentielle. La [documentation de la configuration réseau](https://github.com/introlab/MOvITPlus/blob/master/docs/FR/InstallationLogiciel/ConfigurationSysteme.md#2-configuration-r%c3%a9seau) peut se révéler très utile et, finalement, le respect des spécifications réseaux mentionnées ci-dessous peut être déterminant.

#### Spécification de la connection réseau
Le réseau doit supporter l'**échange de _ping_** avec des serveurs externes ainsi que la découverte et la **communication avec les autres appareils connectés sur le même réseau** pour les fonctions de SSH. Cela signifie donc que certains réseaux publiques se prêtent difficiliement à ce cas d'utilisation. Les "_captive portals_" ou redirections sur une page web avant d'établir une connection (_sign-in page_) peuvent également rendre le processus [beaucoup plus complexe](https://superuser.com/questions/132392/using-command-line-to-connect-to-a-wireless-network-with-an-http-login).
Les réseaux domestiques sont ainsi à prioriser. Un partage de connection LTE peut aussi dépanner.

### Problèmes d'installation
> Notamment avec le script `updateProject.sh` et l'argument `--init-project` ou avec `npm install` et `yarn install`.

Bien qu'il soit probablement plus rapide de recommencer le processus complet, certains problèmes d'installation avec NPM et Yarn peuvent être résous facilement. Ces problèmes peuvent survenir spécialement si le Pi est débranché pendant son initialisation.

Avec le frontend et Yarn :
```bash
cd ~/MOvITPlus/MOvIT-Detect-Frontend && sudo rm -r node_modules/ #Suprime les modules installés
yarn cache clean #Force Yarn à tout télécharger lors de sa prochaine exécution
```

Avec le backend et NPM :
```bash
cd ~/MOvITPlus/MOvIT-Detect-Backend && sudo rm -r node_modules/ #Suprime les modules installés
npm cache verify #Force NPM à tout télécharger lors de sa prochaine exécution
```

### Problèmes de performance
Le Raspberry Zero n'a qu'un seul coeur et il risque de manquer la réception de données des capteurs par les ports SPI et I²C dans certains cas. Les lectures s'excutant à toutes les secondes, il possible qu'une de celles-ci soit uniquement partielle. Le code d'acquisition peut également crasher (la détection des crashs se fait avec un watchdog dans le `main.cpp`) et redémarrer (grâce au service avec *systemd*) à cause de ce même problème de lecture s'il reste pris dans l'attente des données d'un des capteurs.

L'influence la plus importante sur la fréquence de ces crashs est l'utilisation élevée du processeur par d'autres programmes. En plus de la commande `sudo systemctl status movit_acquisition.service` qui retourne l'état du service gérant l'exécution du code d'acquitision, la commande suivante rapporte chacun des démarrages de celui-ci, incluant le démarrage initial. Il est donc possible d'évaluer la fréquence de crash du code d'acquisition.
```bash
journalctl -u movit_acquisition.service | grep Started
```
> La rotation automatique des logs (avec _logrotate_), causera la perte des parties de logs plus anciennes occasionnellement. La commande ci-haut n'est donc pas fiable à 100%, il faut également se fier aux dates et heures enregistrées.

De plus, la commande `htop` peut permettre de visualiser les processus actifs et l'utilisation du processeur.

### Autres problèmes
Certains autres problèmes reliés plus spécifiquement à certaine partie du code sont détaillés dans leur documentation respective. Cette documentation se trouve dans les _README.md_ ainsi que directement dans les parties de code consernées.
____
<br>


# Autre documentation
## Utilisation de Github pour le développement
### Mise à jour des sous-répertoires
Avant un nouveau `git commit`, si désiré, il est possible de changer les tags des versions des sous-répertoires. 
```bash
git submodule update --remote
```
Cette commande permet de mettre à jour les tags des sous-répertoires à leur version la plus récente sur leur `origin/master` respectif. Ces changements apparaissant ensuite dans la liste des changements avec `git status`.

En faisant `git add`, suivit des dossiers et fichiers à mettre à jour, puis les commandes habituelles `git commit` et `git push`, il est possible de rendre ces changements officiels. Le prochain clone avec les sous-modules ira ainsi chercher les versions les plus à jour du répertoire.

> Consultez la [documentation sur les sous-modules GitHub](https://git-scm.com/book/en/v2/Git-Tools-Submodules "GitHub Submodules") pour plus de détails.


## Astuces
- Il est possible de suivre le résultat de l'exécution d'un des scripts qui produit un fichier _.log_ en temps réel avec une commande comme `tail -fn 50 nomdufichier.log`, qui affichera les 50 dernières lignes ainsi que celles qui se rajouteront en temps réel.
- Pour exécuter uniquement certaines parties d'un script, il peut être plus rapide de faire un `if false; then` en début, et `fi` en fin du segment qui doit être ignoré que de commenter toutes les lignes.
- Pour bien comprendre le fonctionnement des scripts : [Bash scripting cheatsheet](https://devhints.io/bash)
<br>
<br>