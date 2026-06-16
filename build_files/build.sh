#!/bin/bash
set -ouex pipefail

# 1. Install the core plugins package
dnf install -y dnf-plugins-core

# 2. Use 'dnf' instead of 'dnf5' for repository management
# This is more likely to trigger the correct plugin integration
dnf copr enable -y srakitnican/cachyos

# 3. For the rest of the installations, you can continue using dnf or dnf5
# They both share the same underlying repository metadata
dnf install -y kernel-cachyos

# 4. Install GNOME Desktop Environment
# Installs the complete Fedora Workstation environment
dnf5 groupinstall -y "Fedora Workstation"

# 5. Configure NVIDIA Drivers
# Using akmod ensures drivers are automatically rebuilt for the CachyOS kernel
dnf5 install -y akmod-nvidia

# 6. Enable System Services
systemctl enable gdm.service
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

# 7. Cleanup
# Remove cached data to keep the image size minimal
dnf5 clean all
