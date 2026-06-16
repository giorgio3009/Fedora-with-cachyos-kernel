#!/bin/bash
set -ouex pipefail

# 1. Abilitazione Repositories
# Installa i repository RPMFusion (necessari per i driver NVIDIA)
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Installa il repository COPR di CachyOS
dnf5 install -y 'dnf-command(copr)'
dnf5 copr enable -y srakitnican/cachyos

# 2. Installazione Kernel CachyOS
# Si consiglia kernel-cachyos per sistemi desktop
dnf5 install -y kernel-cachyos

# 3. Installazione GNOME
# Installa l'intero ambiente desktop Fedora Workstation
dnf5 groupinstall -y "Fedora Workstation"

# 4. Configurazione Driver NVIDIA
# Utilizziamo akmod per permettere al sistema di ricompilare i driver ad ogni update del kernel
dnf5 install -y akmod-nvidia

# 5. Abilitazione Servizi
systemctl enable gdm.service
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

# 6. Pulizia
dnf5 clean all
