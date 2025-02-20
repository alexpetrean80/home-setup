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

  home.packages = with pkgs; [
    tmux-sessionizer
  ];
}
