#!/usr/bin/env bash
set -euo pipefail

dnf -y install --setopt=install_weak_deps=False dnf-plugins-core dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

ln -sf /bin/true /usr/bin/kernel-install
mkdir -p /etc/kernel
echo "do_initrd=no" > /etc/kernel/install.conf

dnf -y install \
    kernel-cachyos-lto \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-devel-matched

KVER=$(rpm -q kernel-cachyos-lto-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
depmod -a "$KVER"

sudo dnf -y install scx-scheds scx-tools

rm -f /usr/bin/kernel-install
rm -f /etc/kernel/install.conf
rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
