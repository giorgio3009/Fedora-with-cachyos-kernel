#!/bin/bash
set -ouex pipefail

# 1. DNF Speedup
# Increases parallel downloads for faster installation
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

# 2. Enable Repositories
# Create the kernel-cachyos repository file using the correct maintainer
cat <<EOF > /etc/yum.repos.d/cachyos.repo
[copr-cachyos]
name=Copr repo for kernel-cachyos owned by bieszczaders
baseurl=https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos/fedora-\$releasever-\$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

# Install RPMFusion repositories (required for NVIDIA drivers)
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
               https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 3. Install Packages
# Kernel CachyOS and GNOME Desktop
dnf install -y kernel-cachyos
dnf groupinstall -y "Fedora Workstation"

# NVIDIA Drivers (akmod automatically builds modules for the CachyOS kernel)
dnf install -y akmod-nvidia

# 4. Enable Services
systemctl enable gdm.service
systemctl enable podman.socket
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

# 5. Cleanup
# Remove cache and temp files to keep the image size minimal
dnf clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
