#!/bin/bash
set -ouex pipefail

# 1. Enable Repositories
# Install the plugin required for dnf5 to manage COPR repositories
dnf5 search plugins-core
#dnf5 install -y dnf-plugins-core
# Enable the CachyOS COPR repository
dnf5 copr enable -y srakitnican/cachyos

# Install RPMFusion repositories (required for NVIDIA drivers)
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf5 install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 2. Install CachyOS Kernel
# kernel-cachyos is recommended for desktop use
dnf5 install -y kernel-cachyos

# 3. Install GNOME Desktop Environment
# Installs the complete Fedora Workstation environment
dnf5 groupinstall -y "Fedora Workstation"

# 4. Configure NVIDIA Drivers
# Using akmod ensures drivers are automatically rebuilt for the CachyOS kernel
dnf5 install -y akmod-nvidia

# 5. Enable System Services
systemctl enable gdm.service
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

# 6. Cleanup
# Remove cached data to keep the image size minimal
dnf5 clean all
