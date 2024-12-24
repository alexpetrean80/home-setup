{ lib, ... }: {
  programs.kitty = {
    enable = true;
    extraConfig = lib.readFile ../../../dotfiles/kitty/kitty.conf;
  };
}
