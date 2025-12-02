#!/bin/sh
# =========================================================
# Script ultra-automatique d'installation complète KDE Plasma
# FreeBSD 15.0
# Matériel : AMD Ryzen 5 7520U + GPU intégré Radeon 610M
# =========================================================

# --- 1. MISE À JOUR DU SYSTÈME ---
echo "[1/9] Mise à jour du système..."
freebsd-update fetch install
pkg update
pkg upgrade -y

# --- 2. INSTALLATION DE XORG ET KDE PLASMA COMPLET ---
echo "[2/9] Installation de Xorg et KDE Plasma complet..."
pkg install -y xorg kde sddm

# --- 3. INSTALLATION DES FONTS ESSENTIELLES ---
echo "[3/9] Installation des polices..."
sudo pkg install -y x11-fonts/ttf-dejavu x11-fonts/ttf-liberation x11-fonts/noto

# --- 4. INSTALLATION DES CODECS AUDIO / VIDEO ---
echo "[4/9] Installation des codecs audio/vidéo..."
pkg install -y multimedia/ffmpeg \
    multimedia/gstreamer1-plugins-good \
    multimedia/gstreamer1-plugins-bad \
    multimedia/gstreamer1-plugins-ugly \
    multimedia/vlc

# --- 5. CONFIGURATION DU DRIVER AMD ---
echo "[5/9] Configuration du driver AMD..."
pkg install -y drm-kmod
sysrc kld_list+="amdgpu"

# --- 6. ACTIVATION DES SERVICES NECESSAIRES ---
echo "[6/9] Activation des services..."
sysrc dbus_enable="YES"
sysrc sddm_enable="YES"
sysrc hald_enable="YES"

# --- 7. CONFIGURATION DU LOGIN AUTOMATIQUE SDDM ---
USER=$(whoami)
echo "[7/9] Configuration du login automatique pour l'utilisateur $USER..."
mkdir -p /usr/local/etc/sddm.conf.d
sh -c "echo '[Autologin]\nUser=$USER\nSession=plasma.desktop' > /usr/local/etc/sddm.conf.d/autologin.conf"

# --- 8. INSTALLATION DES THEMES ET FONDS D'ÉCRAN KDE ---
echo "[8/9] Installation des thèmes et fonds d'écran KDE..."
pkg install -y kde5-lookandfeel kde5-color-schemes kde5-wallpapers

# --- 9. DÉMARRAGE DES SERVICES ---
echo "[9/9] Démarrage des services KDE..."
sudo service dbus start
sudo service sddm start

echo "============================================"
echo "Installation ultra-automatique de KDE Plasma terminée !"
echo "Redémarre le système pour profiter de KDE avec login automatique."
echo "============================================"

# --- 10. Installation de Sudo ---
echo "[10/10] Installation de Sudo"
USER_TO_ADD="sylvain"
pkg install -y sudo

echo "[*] Adding $USER_TO_ADD to wheel group..."
pw groupmod wheel -m "$USER_TO_ADD"

echo "[*] Enabling wheel group in sudoers..."
# Uncomment the wheel line if it exists
sed -i '' 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /usr/local/etc/sudoers
echo "[✓] Done. User '$USER_TO_ADD' should now be able to use sudo."

echo "Fin du script KDE_Install"
