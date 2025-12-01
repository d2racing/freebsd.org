#!/bin/sh
# =========================================================
# Script ultra-automatique d'installation complète KDE Plasma
# FreeBSD 15.0
# Matériel : AMD Ryzen 5 7520U + GPU intégré Radeon 610M
# =========================================================

# --- 1. MISE À JOUR DU SYSTÈME ---
echo "[1/9] Mise à jour du système..."
sudo freebsd-update fetch install
sudo pkg update
sudo pkg upgrade -y

# --- 2. INSTALLATION DE XORG ET KDE PLASMA COMPLET ---
echo "[2/9] Installation de Xorg et KDE Plasma complet..."
sudo pkg install -y xorg kde5 kde-applications sddm \
    kde5-style-breeze kde5-kwin kde5-oxygen-icons kde5-plasma-nm

# --- 3. INSTALLATION DES FONTS ESSENTIELLES ---
echo "[3/9] Installation des polices..."
sudo pkg install -y x11-fonts/ttf-dejavu x11-fonts/ttf-liberation x11-fonts/noto

# --- 4. INSTALLATION DES CODECS AUDIO / VIDEO ---
echo "[4/9] Installation des codecs audio/vidéo..."
sudo pkg install -y multimedia/ffmpeg \
    multimedia/gstreamer1-plugins-good \
    multimedia/gstreamer1-plugins-bad \
    multimedia/gstreamer1-plugins-ugly \
    multimedia/vlc

# --- 5. CONFIGURATION DU DRIVER AMD ---
echo "[5/9] Configuration du driver AMD..."
sudo sysrc kld_list+="amdgpu"

# --- 6. ACTIVATION DES SERVICES NECESSAIRES ---
echo "[6/9] Activation des services..."
sudo sysrc dbus_enable="YES"
sudo sysrc sddm_enable="YES"
sudo sysrc hald_enable="YES"

# --- 7. CONFIGURATION DU LOGIN AUTOMATIQUE SDDM ---
USER=$(whoami)
echo "[7/9] Configuration du login automatique pour l'utilisateur $USER..."
sudo mkdir -p /usr/local/etc/sddm.conf.d
sudo sh -c "echo '[Autologin]\nUser=$USER\nSession=plasma.desktop' > /usr/local/etc/sddm.conf.d/autologin.conf"

# --- 8. INSTALLATION DES THEMES ET FONDS D'ÉCRAN KDE ---
echo "[8/9] Installation des thèmes et fonds d'écran KDE..."
sudo pkg install -y kde5-lookandfeel kde5-color-schemes kde5-wallpapers

# --- 9. DÉMARRAGE DES SERVICES ---
echo "[9/9] Démarrage des services KDE..."
sudo service dbus start
sudo service sddm start

echo "============================================"
echo "Installation ultra-automatique de KDE Plasma terminée !"
echo "Redémarre le système pour profiter de KDE avec login automatique."
echo "============================================"
