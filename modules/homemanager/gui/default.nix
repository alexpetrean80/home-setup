{pkgs, ...}: {
  imports = [
    ../cli
    ./kitty.nix
    ./zed.nix
  ];
}
