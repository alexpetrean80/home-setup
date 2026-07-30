# FALLBACK ONLY. nixos.nix prefers /etc/nixos/hardware-configuration.nix — the
# file `nixos-generate-config` writes on the machine itself — and falls back
# here when that path is absent (evaluating from the mac, or mid-install while
# it still lives under /mnt/etc/nixos).
#
# So: never hand-maintain this for real hardware. On theseus, run
#   nixos-generate-config
# and it takes over automatically on the next `rebnix`.
#
# The values below are the correct set for a Latitude 5401 (NVMe, Intel, UEFI)
# and assume the install partitions are LABELLED, so they work as-is if you
# formatted with:
#   mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
#   mkfs.ext4 -L nixos    /dev/nvme0n1p2
# Anything else (LUKS, btrfs subvolumes, different labels) must come from
# nixos-generate-config.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  # No swap partition — zram handles it (see modules/nixos/core.nix). Add a
  # swapfile here if you want hibernate.
  swapDevices = [];

  networking.useDHCP = lib.mkDefault true;

  hardware.enableRedistributableFirmware = true;
  # Intel microcode + i915 firmware are redistributable; this also pulls the
  # iwlwifi firmware the 5401's Intel AX/AC card needs.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
