{ pkgs, ... }: {
  imports = [
    ../common
    ../server
    ./flatpak.nix
    ./gnome.nix
    # ./hypr.nix
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
    anytype
    telegram-desktop
    signal-desktop
    discord
    gimp
    krita
    darktable
    synology-drive-client
    kdePackages.xwaylandvideobridge
    stremio
		jetbrains-toolbox
		spotify
    obsidian
    nerd-fonts.jetbrains-mono
    vivaldi
		tuxguitar
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
