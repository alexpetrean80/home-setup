{ config
, pkgs
, ...
}: {
  programs = {
    git = {
      enable = true;
      userName = "Alex-Tudor Petrean";
      userEmail = "alex@padfoot.cc";
      diff-so-fancy.enable = true;
      aliases = {
        up = "pull --rebase";
        pfl = "push --force-with-lease";
        ana = "commit --amend --no-edit --allow-empty";
        cb = "checkout -b";
      };
      ignores = [
        "node_modules"
        ".DS_Store"
        ".AppleDouble"
        ".LSOverride"
        "._*" # thumbnails
        # vim related
        "[._]*.s[a-v][a-z]"
        "!*.svg"
        "[._]*.sw[a-p]"
        "[._]s[a-rt-v][a-z]"
        "[._]ss[a-gi-z]"
        "[._]sw[a-p]"
        "[._]*.un~" # persistent undo
      ];
      extraConfig = {
        pull.rebase = true;
        user.useConfigOnly = true;
        init.defaultBranch = "main";
        "url \"ssh://git@github.com/\"" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    lazygit = {
      enable = true;
      settings.gui.theme = {
        activeBorderColor = [
          "#fab387"
          "bold"
        ];
        inactiveBorderColor = [ "#a6adc8" ];
        optionsTextColor = [ "#89b4fa" ];
        selectedLineBgColor = [ "#313244" ];
        cherryPickedCommitBgColor = [ "#45475a" ];
        cherryPickedCommitFgColor = [ "#fab387" ];
        unstagedChangesColor = [ "#f38ba8" ];
        defaultFgColor = [ "#cdd6f4" ];
        searchingActiveBorderColor = [ "#f9e2af" ];
        authorColors."*" = [ "#b4befe" ];
      };
    };

    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
      ];
    };
  };
}
