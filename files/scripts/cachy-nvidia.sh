#!/usr/bin/env bash

set -euo pipefail

dnf -y remove kernel kernel-*
rm -rf /usr/lib/modules/*

dnf -y install --setopt=install_weak_deps=False dnf-plugins-core dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons
dnf -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf -y config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo

dnf -y install --setopt=install_weak_deps=False \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-devel \
    akmod-nvidia \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-settings \
    akmods \
    zenergy \
    scx-scheds

KVER=$(ls /lib/modules | grep cachy | head -n 1)
echo "Building modules for $KVER..."
akmods --force --kernels "$KVER"

depmod -a "$KVER"
dracut --kver "$KVER" --force --add ostree --no-hostonly --reproducible "/usr/lib/modules/$KVER/initramfs.img"

rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
