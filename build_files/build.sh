#!/bin/bash
set -ouex pipefail

# 1. Repo RPMFusion
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Installazione Software e Driver
# Aggiungiamo le dipendenze per compilare i driver NVIDIA durante l'installazione
dnf5 install -y \
    akmod-nvidia \
    kernel-devel \
    gcc \
    gcc-c++ \
    make \
    workstation-product-environment

# 3. Configurazione Servizi
systemctl enable gdm.service
systemctl enable podman.socket
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

# 4. Cleanup
dnf5 clean all
rm -rf /var/cache/* /var/log/* /tmp/*
