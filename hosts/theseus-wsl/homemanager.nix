{pkgs, ...}: {
  imports = [
    ../../modules/homemanager/core.nix
  ];

  # CLI only: the terminal (and any GUI) is on the Windows side, so none of
  # the sway/waybar/wofi/desktop modules apply. username/homeDirectory/
  # stateVersion come from core.nix's Linux defaults, same as theseus.

  home.packages = with pkgs; [
  ];
}
