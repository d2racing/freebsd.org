#!/bin/sh
# ==========================================
# Sauvegarde NAS Synology -> Disque externe ZFS
# ==========================================

# --- CONFIGURATION ---
NAS_MOUNT="/mnt/NAS/192.168.2.250"   # point de montage SMBNETFS du NAS
SHARES=("CLONEZILLA" "DIVERS" "DONNEES" "homes" "LOGICIELS" "photo" "PHOTOSYNC" "STORAGE_ANALYZER")

ZFS_POOL="backup"                     # nom du pool ZFS
ZFS_DATASET="nas_backup"             # dataset pour stocker la sauvegarde
CURRENT="$ZFS_POOL/$ZFS_DATASET/current"

DATE=$(date +%Y-%m-%d_%H-%M)
SNAPSHOT="$ZFS_POOL/$ZFS_DATASET@$DATE"

LOG_FILE="/var/log/nas_backup_zfs.log"

# --- FONCTION DE LOG ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --- VERIFIER QUE LE NAS EST MONTÉ ---
if [ ! -d "$NAS_MOUNT" ]; then
    log "ERREUR : le NAS n'est pas monté sous $NAS_MOUNT. Veuillez monter SMBNETFS."
    exit 1
fi
log "NAS monté : $NAS_MOUNT"

# --- CREER LE DATASET ZFS SI NON EXISTANT ---
if ! zfs list "$CURRENT" >/dev/null 2>&1; then
    log "Création du dataset ZFS : $ZFS_POOL/$ZFS_DATASET"
    sudo zfs create -o mountpoint=/$ZFS_POOL/$ZFS_DATASET "$ZFS_POOL/$ZFS_DATASET"
    sudo zfs create -o mountpoint=/$CURRENT "$CURRENT"
fi

# --- VÉRIFICATION DE L'ESPACE DISPONIBLE ---
AVAIL=$(df -h | grep "$ZFS_POOL/$ZFS_DATASET" | awk '{print $4}')
log "Espace disponible sur ZFS : $AVAIL"

# --- SYNCHRONISATION DES PARTAGES ---
for SHARE in "${SHARES[@]}"; do
    SRC="$NAS_MOUNT/$SHARE"
    DEST="/$CURRENT/$SHARE"

    if [ ! -d "$SRC" ]; then
        log "ATTENTION : le partage $SHARE n'existe pas sur le NAS."
        continue
    fi

    log ">>> Synchronisation du partage $SHARE..."
    sudo mkdir -p "$DEST"

    rsync -aHAX --delete \
        --exclude="#snapshot" --exclude="#recycle" --exclude="@eaDir/" \
        --exclude="@recycle" --exclude="@tmp" --exclude=".SynoIndex*" --exclude="@__thumb/" \
        "$SRC/" "$DEST/" | tee -a "$LOG_FILE" || log "Erreur rsync sur $SHARE"
done

# --- CREATION DU SNAPSHOT ZFS ---
log "Création du snapshot ZFS : $SNAPSHOT"
sudo zfs snapshot "$SNAPSHOT" || { log "Erreur lors du snapshot ZFS"; exit 1; }

# --- ROTATION DES SNAPSHOTS (garder les 7 derniers) ---
OLD_SNAPSHOTS=$(zfs list -t snapshot -o name -s creation -H "$ZFS_POOL/$ZFS_DATASET" | head -n -7)
for snap in $OLD_SNAPSHOTS; do
    log "Suppression ancien snapshot ZFS : $snap"
    sudo zfs destroy "$snap"
done

log "Sauvegarde terminée le $DATE"
exit 0
