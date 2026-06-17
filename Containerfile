# Usa la base bootc ufficiale
FROM quay.io/fedora/fedora-bootc:44

# 1. Installazione Kernel (Gestita direttamente qui)
# bootc/rpm-ostree vedrà questo comando e configurerà il sistema per avviare questo kernel
RUN dnf install -y kernel-cachyos && dnf clean all

# 2. Setup build script
FROM scratch AS ctx
COPY build_files /

# 3. Esecuzione script di configurazione
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    /ctx/build.sh

# 4. Linting finale
RUN bootc container lint
