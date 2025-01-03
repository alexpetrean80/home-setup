{ pkgs
, lib
, ...
}: {
  programs.tmux = {
    enable = true;
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = catppuccin;
        extraConfig = lib.readFile ../../../dotfiles/tmux/catppuccin.conf;
      }
    ];

    extraConfig = lib.readFile ../../../dotfiles/tmux/tmux.conf;
  };
}
