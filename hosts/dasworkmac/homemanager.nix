{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/homemanager/core.nix
    ../../modules/homemanager/zed.nix
    ../../modules/homemanager/vscode.nix
  ];

  home.packages = with pkgs; [
    google-cloud-sdk
  ];

  home = {
    username = "alexp";
    homeDirectory = lib.mkForce "/Users/alexp";
    stateVersion = "24.05";
  };
}
