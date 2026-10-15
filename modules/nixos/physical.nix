# Bare-metal half of the base: everything that assumes a real kernel and real
# hardware — wifi, audio, bluetooth, thermals, power, disks. theseus imports
# it; the WSL host deliberately does not, since Windows owns all of this there
# and NixOS-WSL would either fight these services or silently no-op them.
{pkgs, ...}: {
  networking.networkmanager.enable = true;

  users.users.alexp.extraGroups = [
    "networkmanager"
    "video" # backlight
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
    powerOnBoot = false; # save battery; Plasma's bluetooth applet toggles it
  };

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

  environment.systemPackages = with pkgs; [
    pciutils
    usbutils
    lm_sensors
    powertop
  ];
}
