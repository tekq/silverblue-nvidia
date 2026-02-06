#!/usr/bin/env bash
set -euo pipefail

dnf -y install dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

ln -sf /bin/true /usr/bin/kernel-install
ln -sf /bin/true /usr/bin/dracut

dnf -y swap kernel kernel-cachyos-lto --allowerasing --setopt=install_weak_deps=False
dnf -y install \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open \
    nvidia-driver \
    nvidia-driver-libs \
    nvidia-driver-cuda \
    nvidia-settings

KVER=$(rpm -q kernel-cachyos-lto-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
depmod -a "$KVER"

find /usr/lib/modules -maxdepth 1 -mindepth 1 -type d ! -name "*cachyos*" -exec rm -rf {} +

rm -f /usr/bin/kernel-install /usr/bin/dracut

dnf -y install scx-scheds scx-tools
