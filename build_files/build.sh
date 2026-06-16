#!/bin/bash
set -ouex pipefail

### 1. DNF Speedup
# Velocizza il download dei pacchetti
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

### 2. Add Repositories
# Aggiunta manuale di CachyOS (metodo robusto)
cat <<EOF > /etc/yum.repos.d/cachyos.repo
[srakitnican-cachyos]
name=Copr repo for cachyos owned by srakitnican
baseurl=https://download.copr.fedorainfracloud.org/results/srakitnican/cachyos/fedora-\$releasever-\$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/srakitnican/cachyos/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF

# Installazione RPMFusion
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
               https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

### 3. Install Packages
# Kernel CachyOS e GNOME
dnf install -y kernel-cachyos
dnf groupinstall -y "Fedora Workstation"

# Driver NVIDIA (akmod compila i driver per il nuovo kernel)
dnf install -y akmod-nvidia

### 4. Enable Services
systemctl enable gdm.service
systemctl enable podman.socket
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

### 5. Cleanup
# Pulizia approfondita per mantenere l'immagine piccola
dnf clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
