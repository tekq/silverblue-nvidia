#!/usr/bin/env bash

set -euo pipefail
    
rm -rf /usr/lib/modules/*

dnf -y install --setopt=install_weak_deps=False \
    dnf-plugins-core \
    dnf5-plugins

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

dnf -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo || true
dnf -y config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo || true

dnf -y install --setopt=install_weak_deps=False akmods

dnf -y swap kernel kernel-cachyos-lto

dnf -y swap kernel-devel kernel-cachyos-lto-devel

dnf -y swap zram-generator-defaults cachyos-settings


dnf -y install --setopt=install_weak_deps=False \
    scx-scheds \
    scx-tools \
    scx-manager


VER=$(ls /lib/modules) && \
    akmods --force --kernels $VER --kmod nvidia && \
    depmod -a $VER && \
    dracut --kver $VER --force --add ostree --no-hostonly --reproducible /usr/lib/modules/$VER/initramfs.img
    
rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
