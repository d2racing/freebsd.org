#!/bin/sh
# ==========================================
# Script FreeBSD : Préparer disque dur externe en ZFS
# pour sauvegarde NAS Synology
# ==========================================

# --- CONFIGURATION ---
DISK="/dev/da1"                # Disque externe à formater
POOL_NAME="backup"             # Nom du pool ZFS
DATASET="nas_backup"           # Dataset principal
CURRENT="$DATASET/current"     # Dataset pour rsync
MOUNT_POINT="/mnt/backup"      # Point de montage du pool
USER="TON_USER"                # Utilisateur FreeBSD qui va accéder aux fichiers

# --- FONCTION DE LOG ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --- Vérification que le disque existe ---
if [ ! -b "$DISK" ]; then
    log "ERREUR : Le disque $DISK n'existe pas !"
    exit 1
fi

log "=== Effacement du disque $DISK ==="
sudo gpart destroy -F "$DISK" 2>/dev/null
sudo gpart create -s gpt "$DISK"
sudo gpart add -t freebsd-zfs -a 4k "$DISK"

PARTITION="${DISK}p1"
log "Partition ZFS créée : $PARTITION"

log "=== Création du pool ZFS '$POOL_NAME' ==="
sudo zpool create -f -m "$MOUNT_POINT" "$POOL_NAME" "$PARTITION"
if [ $? -ne 0 ]; then
    log "ERREUR : impossible de créer le pool ZFS"
    exit 1
fi

log "=== Création des datasets ==="
sudo zfs create "$POOL_NAME/$DATASET"
sudo zfs create -o mountpoint="$MOUNT_POINT/$DATASET/current" "$POOL_NAME/$CURRENT"

log "=== Ajustement des permissions pour l'utilisateur $USER ==="
sudo chown -R "$USER":"$USER" "$MOUNT_POINT/$DATASET/current"

log "=== Vérification finale ==="
zfs list
df -h "$MOUNT_POINT"

log "=== DISQUE EXTERNE PRÊT POUR LA SAUVEGARDE NAS ==="
exit 0
