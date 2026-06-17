# 1. Definisci prima lo stage 'ctx' (che copia i file locali)
FROM scratch AS ctx
COPY build_files /

# 2. Definisci l'immagine principale
FROM quay.io/fedora/fedora-bootc:44

# 3. Installa il kernel (ora gestito da bootc/rpm-ostree)
RUN dnf install -y kernel-cachyos && dnf clean all

# 4. Esegui il build script usando lo stage 'ctx' definito sopra
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    /ctx/build.sh

# 5. Linting
RUN bootc container lint
