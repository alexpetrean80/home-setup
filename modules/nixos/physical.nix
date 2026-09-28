# Bare-metal half of the base: everything that assumes a real kernel and real
# hardware — wifi, audio, bluetooth, thermals, power, disks. theseus imports
# it; the WSL host deliberately does not, since Windows owns all of this there
# and NixOS-WSL would either fight these services or silently no-op them.
{pkgs, ...}: {
  networking.networkmanager.enable = true;

  users.users.alexp.extraGroups = [
    "networkmanager"
    "video" # backlight via brightnessctl
    "input"
    "render" # /dev/dri render node (VAAPI, compute)
  ];

  # PipeWire replaces PulseAudio wholesale; rtkit lets it take RT priority.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # save battery; blueman toggles it
  };
  services.blueman.enable = true;

  # Compressed RAM swap instead of a swap partition — 16GB machine, no
  # hibernate. Drop this and add swapDevices if you want suspend-to-disk.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.fstrim.enable = true;
  services.thermald.enable = true; # Intel thermal daemon, real win on H-series

  # Native docker daemon — only where the kernel is ours. On WSL, Docker
  # Desktop on the Windows side provides the engine instead (wsl.nix).
  virtualisation.docker.enable = true;

  # nixos-hardware's common-pc-laptop turns TLP on; these are the knobs worth
  # setting for a Coffee Lake-H chip that throttles hard on battery.
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_BOOST_ON_BAT = 0;
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";
    # Dell's embedded controller supports charge thresholds via the
    # dell_laptop module — spares the battery when docked all day.
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lm_sensors
    powertop
  ];
}
