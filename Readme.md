Voici un exemple de fichier README pour expliquer l'utilisation et la configuration du script que vous avez fourni :

---

# Installation et gestion de serveur de jeu avec SteamCMD

Ce script automatisé est conçu pour faciliter l'installation, la gestion et la sauvegarde de serveurs de jeu utilisant SteamCMD sous Linux.

## Prérequis

Avant d'utiliser ce script, assurez-vous de disposer des éléments suivants :

- Accès administrateur (sudo)
- Connexion Internet active
- Système d'exploitation Linux compatible (testé sur Ubuntu)
- Installation de curl et tar pour les téléchargements et l'extraction de fichiers

## Instructions d'utilisation

1. **Initialisation du script :**
   - Exécutez le script en utilisant `./install_server.sh`.
   - Vous serez invité à fournir les informations suivantes :
     - Nom du dossier où le serveur de jeu sera installé.
     - ID du jeu Steam que vous souhaitez installer.
     - Type de serveur pour Linux (L) ou Windows (W).
     - Connexion avec un compte Steam si nécessaire pour le jeu spécifique.

2. **Installation des dépendances :**
   - Le script vérifiera et installera automatiquement curl et tar si nécessaire.

3. **Installation de SteamCMD :**
   - SteamCMD sera installé dans `/usr/games/steamcmd` si ce n'est pas déjà fait.

4. **Installation du serveur de jeu :**
   - Le script créera un dossier d'installation spécifié par l'utilisateur.
   - Il utilisera SteamCMD pour installer le jeu dans le dossier spécifié.
   - Pour les serveurs Windows, Wine sera installé et utilisé si nécessaire.

5. **Création de scripts de sauvegarde et de mise à jour :**
   - Un script de sauvegarde (`backupserver.sh`) est créé pour sauvegarder le serveur de jeu installé.
   - Un script de mise à jour (`updateserver.sh`) est créé pour mettre à jour le serveur de jeu installé via SteamCMD.

6. **Gestion avancée :**
   - Le script recommande de créer un service systemd pour le serveur afin de le redémarrer automatiquement lors du démarrage.
     ```
     sudo nano /etc/systemd/system/{nom_du_dossier}.service
     ```
   - Des tâches cron peuvent être ajoutées pour automatiser les sauvegardes et les mises à jour du serveur.

## Notes supplémentaires

- Ce script assume que vous avez les droits administratifs nécessaires pour installer des logiciels et créer des services.
- Assurez-vous d'avoir une souscription valide sur Steam pour le jeu que vous essayez d'installer.
- Contactez le support Steam en cas de problèmes liés à l'installation de jeux spécifiques.
