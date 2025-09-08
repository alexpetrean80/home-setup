{lib, ...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = lib.readFile ../../../dotfiles/wezterm/wezterm.lua;
  };
}
