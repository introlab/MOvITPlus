# Pistes d'amélioration pour le projet
## Fiabilité de l'acquisition de données et des machines à états
**Problème 1 :** Le Raspberry Zero n'a qu'un seul coeur et il risque de manquer la réception de données des capteurs par les ports SPI et I²C. Les lectures s'excutant à toutes les secondes, il possible qu'une des lectures soit uniquement partielle.
**Piste de solution :** L'utilisation d'un apparail avec plus de coeurs comme un RaspberryPi 3 pourrait permettre la dédication d'un des coeurs disponible à la lecture et l'exécution du code d'acquisition en C++.

**Problème 2 :** Le code d'acquisition peut crasher (détection des crashs avec un watchdog dans le main) et redémarrer(grâce au service avec *systemd*) à cause du problème 1 s'il reste pris dans l'attente de données d'un capteur.
**Piste de solution :** Éviter les crashs avec la solution du problème 1 ou utiliser la classe FileManager du code pour exporter également les "states" des machines à états (FSM). Il faudrait également inclure l'évolution de cet état (pour les états qui dépendent du temps). Cette modification permettrait de reprendre l'éxécution du code où elle a été laissé en limitant les pertes de données et d'états.

## Installation du système
**Problème :** Le temps d'installation est assez long après le flashage d'une image.
**Piste de solution :** Le projet pourrait être déjà installé dans l'image du système et simplement mis à jour avec le script.

## Sécurité
**Problème :** Plusieurs des parties ne sont pas sécurisées, notamment le mot de passe trop générique pour le *ssh*, les bases de données *Mongo* mais surtout l'accès libre à la page web du backend avec Node-red. De plus, plusieurs modules du frontend et du backend semble comporter des problèmes de sécurité dues à des versions trop vielles.
**Piste de solution :** Refaire un installation complète en étant attentif à toutes les erreurs et *warnings* liées à la sécurité. Remédier à tous les cas où l'authentification devrait être nécessaire (Node-Red, mongo...)