#!/usr/bin/env bash

set -euo pipefail

dnf -y remove kernel kernel-* --allowerasing
rm -rf /usr/lib/modules/*

dnf -y install --setopt=install_weak_deps=False dnf-plugins-core dnf5-plugins

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

if [ ! -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo ]; then
    dnf -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo || true
fi

if [ ! -f /etc/yum.repos.d/terra.repo ]; then
    dnf -y config-manager addrepo --from-repofile=https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo || true
fi

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

rm -f /etc/yum.repos.d/bieszczaders-kernel-cachyos-lto.repo
rm -f /etc/yum.repos.d/bieszczaders-kernel-cachyos-addons.repo
rm -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo
rm -f /etc/yum.repos.d/terra.repo
