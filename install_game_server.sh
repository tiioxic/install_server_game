#!/bin/bash

# Étape 1: Initialisation du script et demande d'informations
echo "Entrez le nom du dossier où le serveur de jeu sera installé :"
read server_folder
echo "Entrez l'ID du jeu que vous souhaitez installer :"
read game_id
echo "Voulez-vous installer un serveur pour Linux ou pour Windows (L/W) ?"
read server_type
echo "Voulez-vous vous connecter avec un compte Steam (nécessaire pour certains jeux) ? (O/N) :"
read login_required

if [ "$login_required" == "O" ]; then
    echo "Entrez votre nom d'utilisateur Steam :"
    read steam_username
    echo "Entrez votre mot de passe Steam :"
    read -s steam_password
fi

# Étape 2: Vérification des dépendances
echo "Vérification des dépendances nécessaires..."
sudo apt update

# Dépendances pour SteamCMD
sudo apt install -y curl tar

# Dépendances pour Wine si serveur Windows
if [ "$server_type" == "W" ]; then
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y wine64 wine32
fi

# Étape 3: Installation de SteamCMD si nécessaire
STEAMCMD_DIR="/usr/games/steamcmd"
if [ ! -d "$STEAMCMD_DIR" ]; then
    echo "Installation de SteamCMD..."
    sudo mkdir -p $STEAMCMD_DIR
    cd $STEAMCMD_DIR
    sudo curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | sudo tar zxvf -
else
    echo "SteamCMD est déjà installé."
fi

# Étape 4: Création du dossier d'installation du serveur
INSTALL_DIR="$HOME/${server_folder}_server"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Étape 5: Installation du jeu en fonction du type de serveur
if [ "$server_type" == "L" ]; then
    echo "Installation du serveur de jeu pour Linux..."
    if [ "$login_required" == "O" ]; then
        echo "Connexion à Steam avec les informations utilisateur..."
        sudo $STEAMCMD_DIR/steamcmd.sh +force_install_dir "$INSTALL_DIR" +login "$steam_username" "$steam_password" +app_update $game_id validate +quit
    else
        sudo $STEAMCMD_DIR/steamcmd.sh +force_install_dir "$INSTALL_DIR" +login anonymous +app_update $game_id validate +quit
    fi
elif [ "$server_type" == "W" ]; then
    echo "Installation du serveur de jeu pour Windows..."
    if [ "$login_required" == "O" ]; then
        echo "Connexion à Steam avec les informations utilisateur..."
        sudo $STEAMCMD_DIR/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$INSTALL_DIR" +login "$steam_username" "$steam_password" +app_update $game_id validate +quit
    else
        sudo $STEAMCMD_DIR/steamcmd.sh +@sSteamCmdForcePlatformType windows +force_install_dir "$INSTALL_DIR" +login anonymous +app_update $game_id validate +quit
    fi
fi

echo "Installation terminée dans le dossier $INSTALL_DIR"

# Étape 6: Création du script de sauvegarde
BACKUP_SCRIPT="$HOME/backupserver.sh"
echo "Création du script de sauvegarde à $BACKUP_SCRIPT..."

cat <<EOL > $BACKUP_SCRIPT
#!/bin/bash

# Répertoire où se trouvent les sauvegardes
BACKUP_DIR="\$HOME/backups_server"
# Répertoire du serveur de jeu
SERVER_DIR="\$HOME/${server_folder}"
# Nom de la sauvegarde avec la date et l'heure
BACKUP_NAME="backup_${server_folder}_\$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "\$BACKUP_DIR"

# Créer la sauvegarde
tar -czvf "\$BACKUP_DIR/\$BACKUP_NAME" -C "\$SERVER_DIR" .

# Limiter le nombre de sauvegardes à 4
NUM_BACKUPS=\$(ls "\$BACKUP_DIR" | wc -l)
if [ "\$NUM_BACKUPS" -gt 4 ]; then
    # Supprimer les sauvegardes les plus anciennes
    ls -t "\$BACKUP_DIR" | tail -n +5 | xargs -I {} rm -- "\$BACKUP_DIR/{}"
fi
EOL

# Rendre le script de sauvegarde exécutable
chmod +x "$BACKUP_SCRIPT"

echo "Le script de sauvegarde a été créé et rendu exécutable."

# Étape 7: Création du script de mise à jour
UPDATE_SCRIPT="$HOME/updateserver.sh"
echo "Création du script de mise à jour à $UPDATE_SCRIPT..."

cat <<EOL > $UPDATE_SCRIPT
#!/bin/bash

# Mise à jour du serveur
sudo $STEAMCMD_DIR/steamcmd.sh +force_install_dir "$HOME/${server_folder}" +login anonymous +app_update $game_id validate +quit
EOL

# Rendre le script de mise à jour exécutable
chmod +x "$UPDATE_SCRIPT"

echo "Le script de mise à jour a été créé et rendu exécutable."
echo "Vous pouvez créer un service ce qui permettra de redémarrer le serveur lors de reboot de la machine ou du serveur"
echo "executer ceci sudo nano /etc/systemd/system/$server_folder.service"
echo "Et vous pouvez aussi ajoute des cron pour automatiser les backups ou les updates"
