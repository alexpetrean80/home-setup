{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/homemanager/core.nix
  ];


  home.packages = with pkgs; [
  ];

  home = {
    username = "alexp";
    homeDirectory = lib.mkForce "/Users/alexp";
    stateVersion = "24.05";
  };
}
