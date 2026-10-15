{pkgs, ...}: {
  imports = [
    ../../modules/homemanager/core.nix
  ];

  # CLI only: the terminal (and any GUI) is on the Windows side, so the kde
  # module does not apply. username/homeDirectory/stateVersion come from
  # core.nix's Linux defaults, same as theseus.

  home.packages = with pkgs; [
  ];

  # Belt and braces for link opening (see modules/nixos/wsl.nix): if xdg-open
  # lands in its generic path instead of detecting WSL, `xdg-mime query
  # default` resolves to wsl-open and the URL still reaches the Windows
  # browser. wsl-open (system package) ships no .desktop file, so define one.
  xdg.desktopEntries.wsl-open = {
    name = "wsl-open";
    exec = "wsl-open %u";
    terminal = false;
    noDisplay = true;
    mimeType = ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"];
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "wsl-open.desktop";
      "x-scheme-handler/http" = "wsl-open.desktop";
      "x-scheme-handler/https" = "wsl-open.desktop";
    };
  };
}
