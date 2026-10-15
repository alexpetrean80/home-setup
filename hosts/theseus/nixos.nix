{
  inputs,
  pkgs,
  ...
}: let
  # Use the machine's own generated hardware config when it exists, so disks,
  # microcode and detected modules always match reality. Reading an absolute
  # path makes evaluation impure — rebnix and init.sh pass `--impure` for
  # exactly this. The checked-in copy is the fallback: it keeps `nix eval`
  # working from the mac and during `nixos-install`, where the file still
  # lives under /mnt.
  #
  # CAUTION: in pure eval, pathExists on an absolute path returns false
  # SILENTLY even when the file exists — no error. Any rebuild on theseus
  # that forgets `--impure` therefore builds against the fallback's
  # label-based filesystems and won't boot unless the partitions are
  # actually labelled BOOT/nixos.
  machineHardware = /etc/nixos/hardware-configuration.nix;
  hardware =
    if builtins.pathExists machineHardware
    then machineHardware
    else ./hardware-configuration.nix;
in {
  imports = [
    hardware
    # Dell Latitude 5401: Coffee Lake-H (9th gen i5/i7) + UHD 630, NVMe, laptop.
    # nixos-hardware has no 5401 profile, so compose the generic ones: intel
    # microcode + i915/VAAPI stack, fstrim. Its TLP stays off: Plasma brings
    # power-profiles-daemon, and powerdevil switches profiles on AC/battery
    # (modules/homemanager/kde.nix).
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ../../modules/nixos/core.nix
    ../../modules/nixos/physical.nix
    ../../modules/nixos/kde.nix
    ../../modules/nixos/steam.nix
  ];

  networking.hostName = "theseus";

  # UHD 630 is Gen9. iHD (intel-media-driver) covers Gen8+ for VAAPI, so pin it
  # and skip the i965 driver nixos-hardware would otherwise also install.
  # OpenCL needs the Gen8-11 compute runtime. mediaRuntime is left at the
  # Gen12+ default on purpose: the Gen8-11 one (intel-media-sdk) is EOL and
  # flagged insecure in nixpkgs, and nothing here uses oneVPL — VAAPI through
  # iHD is what actually decodes video.
  hardware.intelgpu = {
    vaapiDriver = "intel-media-driver";
    computeRuntime = "legacy";
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # keep /boot (ESP) from filling up
      };
      efi.canTouchEfiVariables = true;
    };
    # 2019 hardware is fully supported by the default LTS kernel; the newer
    # kernel is here for i915 fixes and better wayland/power behaviour.
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # i915 power savings that are off by default (safe on Gen9).
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
    ];
  };

  # Latitude firmware ships on LVFS: `fwupdmgr refresh && fwupdmgr update`.
  services.fwupd.enable = true;

  # Charge to 80%, resume below 75% — spares the battery when docked all day.
  # dell-laptop adds these knobs to BAT0 only after the battery itself shows
  # up, which is why this waits instead of being a udev rule on BAT0's add.
  systemd.services.battery-charge-limit = {
    description = "Cap battery charging at 80%";
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "oneshot";
    script = ''
      bat=/sys/class/power_supply/BAT0
      for _ in $(seq 30); do
        [ -e "$bat/charge_control_end_threshold" ] && break
        sleep 1
      done
      echo 75 > "$bat/charge_control_start_threshold"
      echo 80 > "$bat/charge_control_end_threshold"
    '';
  };

  system.stateVersion = "26.05";
}
