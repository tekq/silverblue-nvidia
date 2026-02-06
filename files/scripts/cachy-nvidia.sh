#!/usr/bin/env bash
set -euo pipefail

dnf -y install dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

if [ -f /usr/lib/kernel/install.d/05-rpmostree.install ]; then
    echo "Disabling rpm-ostree kernel hook during build..."
    mv /usr/lib/kernel/install.d/05-rpmostree.install /usr/lib/kernel/install.d/05-rpmostree.install.bak
fi

dnf -y swap kernel kernel-cachyos-lto --allowerasing --setopt=install_weak_deps=False
dnf -y install \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open \
    nvidia-driver \
    nvidia-driver-libs \
    nvidia-driver-cuda

KVER=$(rpm -q kernel-cachyos-lto-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
depmod -a "$KVER"

find /usr/lib/modules -maxdepth 1 -mindepth 1 -type d ! -name "*cachyos*" -exec rm -rf {} +

if [ -f /usr/lib/kernel/install.d/05-rpmostree.install.bak ]; then
    mv /usr/lib/kernel/install.d/05-rpmostree.install.bak /usr/lib/kernel/install.d/05-rpmostree.install
fi

dnf -y install scx-scheds scx-tools
