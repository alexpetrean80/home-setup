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
    inputs.zen-browser.packages."${system}".specific
    obsidian
    telegram-desktop
    signal-desktop
    discord
    gimp
    krita
    darktable
    nerdfonts
    synology-drive-client
    xwaylandvideobridge
    netbird-ui
    stremio
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
