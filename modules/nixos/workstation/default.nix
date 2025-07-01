{pkgs, ...}: {
  imports = [
    ../common
    ../server
    ./flatpak.nix
    ./plasma.nix
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
    bitwarden
    signal-desktop
    discord
    gimp
    krita
    darktable
    synology-drive-client
    kdePackages.xwaylandvideobridge
    stremio
    spotify
    nerd-fonts.jetbrains-mono
		nerd-fonts.zed-mono
    vivaldi
    tuxguitar
    calibre
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
