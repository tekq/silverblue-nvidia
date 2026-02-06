#!/usr/bin/env bash
set -euo pipefail

# 1. Setup Repos
dnf -y install --setopt=install_weak_deps=False dnf-plugins-core dnf5-plugins
dnf -y copr enable bieszczaders/kernel-cachyos-lto
dnf -y copr enable bieszczaders/kernel-cachyos-addons

# 2. MASK DRACUT (The "Silverblue Trick")
# We point kernel-install to /bin/true so the scriptlet 'succeeds' instantly
ln -sf /bin/true /usr/bin/kernel-install

# 3. Perform the Atomic Swap
# Including nvidia-open here ensures the kmod is pulled with the kernel
dnf -y swap kernel kernel-cachyos-lto \
    --allowerasing \
    --setopt=install_weak_deps=False

dnf -y install \
    kernel-cachyos-lto-core \
    kernel-cachyos-lto-modules \
    kernel-cachyos-lto-nvidia-open \
    kernel-cachyos-lto-devel-matched

# 4. MANUAL DEPMOD
# Since we masked the automatic hook, we must generate modules.dep ourselves
# so the system is bootable and BlueBuild is happy.
KVER=$(rpm -q kernel-cachyos-lto-core --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
depmod -a "$KVER"

# 5. Remove any leftover Fedora kernel files to prevent the 'Multiple Kernels' error
find /usr/lib/modules -maxdepth 1 -type d -name "6.*.fc43.x86_64" ! -name "*cachyos*" -exec rm -rf {} +

dnf -y install scx-scheds scx-tools

# 6. UNMASK and Cleanup
rm -f /usr/bin/kernel-install
rm -f /etc/yum.repos.d/{*copr*,*multimedia*,*terra*}.repo
