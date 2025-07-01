{ lib, ... }: {


  programs.kitty = {


    enable = true;More actions


    extraConfig = lib.readFile ../../../dotfiles/kitty/kitty.conf;


  };


}