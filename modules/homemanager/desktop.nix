{config, lib, pkgs, ...}: {
  imports = [
    ./core.nix
  ];

  catppuccin = {
    flavor = "mocha";
    accent = "lavender";
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-lavender-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "standard";
        variant = "mocha";
      };
    };
    gtk4.theme = config.gtk.theme;
  };

  catppuccin.gtk.icon.enable = true;

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  catppuccin.kvantum.enable = true;
  catppuccin.starship.enable = true;

  home = {
    packages = with pkgs; [
      ghostty
      zed-editor
    ];

    file.".config/ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/ghostty";
    };

    file.".config/zed" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/zed";
    };
  };
}
