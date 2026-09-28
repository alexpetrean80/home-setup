# Host-agnostic NixOS base: nix daemon, locale, users, shell. Anything that
# needs real hardware or our own kernel (wifi, audio, bluetooth, power, the
# docker daemon) lives in physical.nix; everything desktop-shaped in sway.nix /
# steam.nix. This file plus wsl.nix is the entire system half of the WSL host,
# so it has to stay hardware-free.
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

  networking.firewall.enable = true;

  users.users.alexp = {
    isNormalUser = true;
    description = "Alex Petrean";
    shell = pkgs.zsh;
    # Hardware groups (networkmanager, video, input, render) are added by
    # physical.nix — on WSL the networkmanager group does not even exist.
    # `docker` exists on both: created by the native daemon (physical.nix) or
    # by the Docker Desktop integration (wsl.nix).
    extraGroups = [
      "wheel"
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

  environment.systemPackages = with pkgs; [
    git # needed before home-manager's copy exists (installer, recovery)
  ];

  # OpenSSH off by default — flip on if you want to reach a host remotely.
  services.openssh.enable = lib.mkDefault false;
}
