{pkgs, ...}: {
  imports = [
    ../../modules/homemanager/core.nix
    ../../modules/homemanager/kde.nix
  ];

  # username/homeDirectory/stateVersion come from core.nix, which already
  # carries the Linux values (/home/alexp) — the darwin host is the one that
  # has to override them.

  home.packages = with pkgs; [
  ];
}
