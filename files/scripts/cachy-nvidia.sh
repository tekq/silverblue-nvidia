#!/usr/bin/env bash

set -euo pipefail

dnf -y install --setopt=install_weak_deps=False \
    dnf-plugins-core \
    dnf5-plugins

dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

dnf -y install kernel-cachyos-lto kernel-cachyos-lto-devel-matched

rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
