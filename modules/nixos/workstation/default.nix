{ pkgs, ... }: {
  imports = [
    ../common
    ../server
    ./gnome.nix
    ./steam.nix
  ];

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    obsidian
    telegram-desktop
    signal-desktop
    discord
    gimp
    krita
    darktable
    synology-drive-client
    xwaylandvideobridge
    stremio
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
