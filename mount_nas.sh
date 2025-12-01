#!/bin/sh

MOUNT_POINT="/mnt/NAS"

# Vérifier et charger FUSE si nécessaire
if ! kldstat | grep -q fusefs; then
    echo "Chargement du module fusefs..."
    sudo kldload fusefs || { echo "Échec du chargement fusefs"; exit 1; }
fi

# Vérifier si déjà monté
if mount | grep -q "$MOUNT_POINT"; then
    echo "Le NAS est déjà monté sous $MOUNT_POINT."
    exit 0
fi

echo "Montage du NAS Synology (SMB3)..."
smbnetfs "$MOUNT_POINT"

sleep 1

echo ""
echo "NAS monté. Partages disponibles :"
ls "$MOUNT_POINT/192.168.2.250"
