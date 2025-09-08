{pkgs, ...}: {
  imports = [
    ../cli
    ./kitty.nix
    ./wezterm.nix
    ./zed.nix
  ];
}
