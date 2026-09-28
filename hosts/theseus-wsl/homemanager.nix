{pkgs, ...}: {
  imports = [
    ../../modules/homemanager/core.nix
  ];

  # CLI only: the terminal (and any GUI) is on the Windows side, so none of
  # the sway/waybar/wofi/desktop modules apply. username/homeDirectory/
  # stateVersion come from core.nix's Linux defaults, same as theseus.

  home.packages = with pkgs; [
  ];

  # Belt and braces for link opening (see modules/nixos/wsl.nix): if xdg-open
  # lands in its generic path instead of detecting WSL, `xdg-mime query
  # default` resolves to wslview and the URL still reaches the Windows browser.
  # `wslview.desktop` ships with wslu (system package, so on XDG_DATA_DIRS).
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "wslview.desktop";
      "x-scheme-handler/http" = "wslview.desktop";
      "x-scheme-handler/https" = "wslview.desktop";
    };
  };
}
