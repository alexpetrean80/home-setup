{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./core.nix
  ];

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    signal-desktop
    discord
    gimp
    krita
    darktable
    synology-drive-client
    stremio-linux-shell
    tidal-hifi
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.zed-mono
    vivaldi
    tuxguitar
    calibre
    reaper
    yabridge
    yabridgectl
    networkmanager_dmenu
    rofi-bluetooth
    wl-clipboard
    libnotify
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    kdePackages.sddm-kcm
  ];

  musnix.enable = true;

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          leftmeta = "layer(meta_mac)";
          leftalt = "leftalt";
        };
        meta_mac = {
          c = "C-c";
          v = "C-v";
          x = "C-x";
          t = "C-t";
          w = "C-w";
          q = "A-f4";
        };
      };
    };
  };

  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "${pkgs.tlp}/bin/tlp";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  security.rtkit.enable = pkgs.lib.mkDefault true;
}
