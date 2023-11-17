#!/bin/bash
#
# facetimehd-reinstall.sh
#
# Reinstalls the facetimehd kernel module. We do this because each time we bump
# the kernel, this module usually breaks. The script can be set as a pacman hook
# to run after each kernel bump. The script should be run as root.
#
# Ref.:
# https://github.com/patjak/facetimehd/wiki/Installation#get-started-on-arch
set -euo pipefail

#
# These text wrangles are meant to convert package numbers from pacman style to
# uname style. So:
#   5.18.16.arch1-1 -> 5.18.16-arch1-1
#   5.15.58-2 -> 5.15.58-2-lts
#
kernel_release=$(pacman -Qi linux | grep Version | \
  perl -ple 's/^Version.*([0-9]+\.[0-9]+\.[0-9]+)\.(.*)$/$1-$2/')
kernel_release_lts=$(pacman -Qi linux-lts | grep Version | \
  perl -ple 's/^Version.*([0-9]+\.[0-9]+\.[0-9]+.*)$/$1-lts/')
cd /home/adam/builds/bcwc_pcie || exit 1

#
# Linux
#
echo "*** Linux FacetimeHD driver ***"
echo "[linux] make clean"
KERNELRELEASE=$kernel_release make clean
echo "[linux] make"
KERNELRELEASE=$kernel_release make
echo "[linux] make install"
KERNELRELEASE=$kernel_release make install
echo "[linux] depmod"
depmod "$kernel_release"
if ! (modprobe --set-version "$kernel_release" -r bdc_pci); then
  echo "[linux] Removal of module bdc_pci failed."
fi
if ! (modprobe --set-version "$kernel_release" -r facetimehd); then
  echo "[linux] Removal of module facetimehd failed."
fi
echo "[linux] Installing module facetimehd"
modprobe --set-version "$kernel_release" facetimehd

#
# Linux LTS
#
echo "*** Linux-LTS FacetimeHD driver ***"
echo "[linux-lts] make clean"
KERNELRELEASE=$kernel_release_lts make clean
echo "[linux-lts] make"
KERNELRELEASE=$kernel_release_lts make
echo "[linux-lts] make install"
KERNELRELEASE=$kernel_release_lts make install
echo "[linux-lts] depmod"
depmod "$kernel_release_lts"
if ! (modprobe --set-version "$kernel_release_lts" -r bdc_pci); then
  echo "[linux-lts] Removal of module bdc_pci failed."
fi
if ! (modprobe --set-version "$kernel_release_lts" -r facetimehd); then
  echo "[linux-lts] Removal of module facetimehd failed."
fi
echo "[linux-lts] Installing module facetimehd"
modprobe --set-version "$kernel_release_lts" facetimehd
