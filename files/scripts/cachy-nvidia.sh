#!/usr/bin/env bash

set -euo pipefail

dnf -y remove \
    kernel \
    kernel-* rm -rf /usr/lib/modules/*

dnf -y install --setopt=install_weak_deps=False \
    dnf-plugins-core \
    dnf5-plugins

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

dnf -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo || true
dnf -y config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo || true

dnf -y install --setopt=install_weak_deps=False \
    kernel-cachyos-lto \
    kernel-cachyos-lto-devel \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-settings \
    akmod-nvidia \
    akmods \
    scx-scheds \
    scx-tools \
    scx-manager

dnf -y swap zram-generator-defaults cachyos-settings

VER=$(ls /lib/modules | grep cachy | head -n 1)

if [ -z "$VER" ]; then
    echo "Error: No kernel found in /lib/modules"
    exit 1
fi

echo "Building modules for $VER..."
akmods --force --kernels "$VER" --kmod nvidia

depmod -a "$VER"
dracut --kver "$VER" --force --add ostree --no-hostonly --reproducible "/usr/lib/modules/$VER/initramfs.img"
rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo

echo "Build complete for CachyOS LTO kernel: $VER"
