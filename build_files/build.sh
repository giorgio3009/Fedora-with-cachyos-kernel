#!/bin/bash
set -ouex pipefail

### 1. DNF Speedup
# Velocizza il download dei pacchetti
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

### 2. Add Repositories
# Aggiunta del repository CachyOS
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

# Installazione RPMFusion
dnf5 install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

### 3. Install Packages
# Installazione Kernel CachyOS (senza noscripts per permettere a dracut di girare)
dnf5 install -y kernel-cachyos

# Installazione dipendenze per compilazione moduli (necessarie per NVIDIA/akmod)
dnf5 install -y kernel-devel gcc gcc-c++ make

# Installazione Ambiente Desktop
dnf5 group install -y workstation-product-environment

# Driver NVIDIA
dnf5 install -y akmod-nvidia

### 4. Ensure Initramfs generation
# Forza la rigenerazione di tutte le immagini initramfs per sicurezza
for kver in $(ls /lib/modules); do
    dracut -f "/boot/initramfs-${kver}.img" "${kver}"
done

### 5. Enable Services
systemctl enable gdm.service
systemctl enable podman.socket
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

### 6. Cleanup
dnf5 clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
