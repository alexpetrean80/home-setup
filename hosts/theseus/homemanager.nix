{pkgs, ...}: {
  imports = [
    ../../modules/homemanager/core.nix
    ../../modules/homemanager/sway.nix
    ../../modules/homemanager/waybar.nix
    ../../modules/homemanager/wofi.nix
    ../../modules/homemanager/desktop.nix
  ];

  # username/homeDirectory/stateVersion come from core.nix, which already
  # carries the Linux values (/home/alexp) — the darwin host is the one that
  # has to override them.

  home.packages = with pkgs; [
  ];
}
