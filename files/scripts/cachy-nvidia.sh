#!/usr/bin/env bash
set -euo pipefail

dnf -y install dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

ln -sf /bin/true /usr/bin/kernel-install

dnf -y swap kernel kernel-cachyos-lto \
    --allowerasing \
    --setopt=install_weak_deps=False

dnf -y install \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open \
    kernel-cachyos-lto-devel-matched \
    nvidia-driver \
    nvidia-driver-libs \
    nvidia-settings \
    nvidia-driver-cuda

KVER=$(rpm -q kernel-cachyos-lto-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
depmod -a "$KVER"

find /usr/lib/modules -maxdepth 1 -type d -name "6.*.fc43.x86_64" ! -name "*cachyos*" -exec rm -rf {} +

dnf -y install scx-scheds scx-tools

rm -f /usr/bin/kernel-install
rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
