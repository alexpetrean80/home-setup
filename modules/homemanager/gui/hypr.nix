{ config, ... }: {
  home.file = {
    ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/hypr";
    ".config/hyprpanel".source = ../../../dotfiles/hyprpanel;
    ".config/rofi".source = ../../../dotfiles/rofi;
    ".config/kitty".source = ../../../dotfiles/kitty;
  };
}
