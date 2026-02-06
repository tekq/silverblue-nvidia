#!/usr/bin/env bash

set -euo pipefail

dnf -y install --setopt=install_weak_deps=False \
    dnf-plugins-core \
    dnf5-plugins

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

rpm-ostree override remove kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra --install kernel-cachyos-lto --install kernel-cachyos-lto-core --install kernel-cachyos-lto-modules --install kernel-cachyos-lto-devel --install kernel-cachyos-lto-devel-matched

rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
