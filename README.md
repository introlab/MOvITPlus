

# MOvIT +
Ce répertoire contient tous les éléments nécessaires pour faire fonctionner un système MOvIt+

#### Installation de MOvIt+ et de ces sous-répertoires 
L'installation de MOvIt requiert un `git clone` habituel et 

|Installer initialement| Mettre à jour répertoire parent|Mettre à jour les sous-répertoires|
|-|-|-|
|`git clone [...] --recurse-submodules`|`git pull`|`git submodule update --remote`|

https://git-scm.com/book/en/v2/Git-Tools-Submodules
```bash
git submodule update --init --recursive
```
**Mettre à jour le répertoire parent**
   - liens vers les bonnes versions des sous-répertoires
   - scripts de démarrage et de mise à jour

```bash
git pull
```
```bash
# Mettre à jour tous les sous-répertoires à leur version la plus récente sur leur origin/master respectifs
git submodule update --remote

# Mettre à jour le master du répertoire parent avec ces dernières versions des masters des sous-répertoires.
git add [les dossiers des répertoires]
git commit -m "message du commit"
git push
```

## MOvIT-Detect
Contiens tout le code nécessaire pour communiquer avec des capteurs via I2C et SPI à partir d'un Raspberry Pi Zero W et des circuits imprimés faits sur mesure. La communication avec le backend est faites via MQTT. Ce code fonctionne sur Raspberry Pi Zero W, ou tout autre processeur ARM basé sur le processeur BroadCom bcm2835.

## MOvIT-Detect-Backend
C'est le backend du système, il a été conçu en node-red, ce qui permet d'effectuer des modifications rapidement et simplement. Il reçoit les données via MQTT du code d'acquisition et enregistre les données dans une base de données MongoDB 2 localement. Les donnes sont alors traitées et peuvent être affichées à l'aide de requête GET et POST, également utilisé par le frontend pour afficher l'information.

## MOvIT-Detect-Frontend
C'est le frontend du système, utilisé par le clinicien et le patient. Ce code utilise React et Redux afin de créer une application web fluide. Les données sont affichées sous forme de graphique facile à lire et interprétées. 

## MOvIT-Hardware
Contiens tous les fichiers de fabrication pour concevoir, ce qui permet de recréer le système en entier.
