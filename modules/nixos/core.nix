# Host-agnostic NixOS base: nix daemon, locale, networking, audio, users.
# Everything desktop-shaped lives in sway.nix / steam.nix.
{
  pkgs,
  lib,
  ...
}: {
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "alexp"];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # ASSUMPTION: change if you're not on Romanian time.
  time.timeZone = "Europe/Bucharest";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  users.users.alexp = {
    isNormalUser = true;
    description = "Alex Petrean";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video" # backlight via brightnessctl
      "input"
      "render" # /dev/dri render node (VAAPI, compute)
      "docker"
    ];
  };

  # zsh is configured by home-manager, but it has to be a valid login shell and
  # NixOS needs the system-level hook for its completion/env setup.
  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    # curses pinentry: works over ssh and inside the terminal, no GTK detour.
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = false;
  };

  virtualisation.docker.enable = true;

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

  # Secret storage for discord/browser logins (libsecret backend).
  services.gnome.gnome-keyring.enable = true;

  services.fstrim.enable = true;
  services.thermald.enable = true; # Intel thermal daemon, real win on H-series

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

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono # waybar/wofi/ghostty all assume this
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = ["JetBrainsMono Nerd Font Mono"];
      emoji = ["Noto Color Emoji"];
    };
  };

  environment.systemPackages = with pkgs; [
    git # needed before home-manager's copy exists (installer, recovery)
    pciutils
    usbutils
    lm_sensors
    powertop
  ];

  # OpenSSH off by default — flip on if you want to reach theseus remotely.
  services.openssh.enable = lib.mkDefault false;
}
