# Installation complète
Le projet est séparé en plusieurs parties. Il y a la partie acquisitions des données (MOvIT-Detect), la partie backend (MOvIT-Detect-Backend) et la partie frontend (MOvIT-Detect-Frontend). Chacune des parties doit être installée individuellement. Il est recommandé d'installé la partie acquisition, suivi du backend et finalement le frontend. Chacune des parties possède son propre guide d'installation.

## 1. Instalation de MOvIT-Detect
Le guide d'installation de MOvIT-Detect se trouve [ici](/MOvIT-Detect/README.md)

## 2. Instalation de MOvIT-Detect-Backend
Le guide d'installation de MOvIT-Detect-Backend se trouve [ici](/MOvIT-Detect-Backend/README.md)

## 3. Instalation de MOvIT-Detect-Frontend
Le guide d'installation de MOvIT-Detect-Frontend se trouve [ici](/MOvIT-Detect-Frontend/README.md)

## 4. Configuration du point d'accès
La configuration du mode point d'accès n'est pas obligatoire bien que très utile pour ce connecter sur le fauteuil sans accès internet. Le guide de configuration en point d'accès se trouve [ici](MOvITPlus/docs/FR/InstallationLogiciel/ConfigurationReseau.md)

## 5. Démarrage automatique
Le démarrage automatique est optionnel bien que fortement recommande. Les instructions pour ajouter un service au démarrage se trouve [ici](/MOvITPlus/docs/FR/InstallationLogiciel/CreationService.md)

# Déverminage
Il faut s'assurer que tout soit déjà lancé, il y a trois programmes a partir soit, l'interface web, le code d'acquisition et le backend. Le temps de démarrage est d'environ 6 minutes.

## Interface web
Il est possible de confirmer que l'interface web est bel et bien lancée et prête en se connectant sur le raspberry pi au port 3000

## Le backend
Il est possible de confirmer que l'interface web de node-red est bel et bien lancé et prête en se connectant sur le raspberry pi au port 1880. L'interface de node-red devrait s'afficher indiquant que le backend est prêt.

## Code d'acquisition
Le code d'acquisition une fois lancé affiche l'état des différents capteurs, il faut s'assurer que les capteurs connectés affichent les bonnes valeurs. Si tel n'est pas le cas, il faut vérifier les capteurs et leur fonctionnement. La commande `i2cdetect -y 1` permet de confirmer que le raspberry pi voit bel et bien les capteurs connectés. Un programme comme MQTTfx permet d'afficher les messages MQTT, et permet de confirmer l'envoi et la réception de données.
