{ ... }: {
  home.file = {
    ".config/hypr".source = ../../../dotfiles/hypr;
    ".config/hyprpanel".source = ../../../dotfiles/hyprpanel;
    ".config/rofi".source = ../../../dotfiles/rofi;
  };
}
