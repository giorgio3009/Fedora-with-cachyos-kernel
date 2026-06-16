#!/bin/bash
set -ouex pipefail

### 1. DNF Speedup
# Velocizza il download dei pacchetti
sed -i '/^\[main\]/a max_parallel_downloads=10' /etc/dnf/dnf.conf

### 2. Add Repositories
# Aggiunta del repository CachyOS (bieszczaders)
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
dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
               https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

### 3. Install Packages
# Kernel CachyOS (usiamo --setopt=tsflags=noscripts per evitare errori di dracut durante la build)
dnf install -y kernel-cachyos --setopt=tsflags=noscripts

# Installazione Ambiente Desktop
dnf5 group install -y workstation-product-environment

# Driver NVIDIA (akmod compilerà i moduli al primo boot)
dnf install -y akmod-nvidia

### 4. Enable Services
systemctl enable gdm.service
systemctl enable podman.socket
systemctl enable nvidia-suspend.service
systemctl enable nvidia-hibernate.service
systemctl enable nvidia-resume.service

### 5. Cleanup
# Pulizia per ridurre le dimensioni dell'immagine
dnf clean all
rm -rf /run/dnf /run/selinux-policy /var/lib/dnf
