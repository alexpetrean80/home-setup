{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
    neovim = {
      enable = true;
      package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = lib.importTOML ../../dotfiles/starship.toml;
    };

    tmux = {
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
          plugin = inputs.minimal-tmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
        }
      ];
      extraConfig = lib.readFile ../../dotfiles/dot_tmux.conf;
    };

    git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        alias = {
          up = "pull --rebase";
          pfl = "push --force-with-lease";
          ana = "commit --amend --no-edit --allow-empty";
          cb = "checkout -b";
        };
        user = {
          name = "Alex Petrean";
          email = "git@alexptr.addy.io";
          useConfigOnly = true;
        };
        pull.rebase = true;
        init.defaultBranch = "main";
        "url \"ssh://git@github.com/\"" = {
          insteadOf = "https://github.com/";
        };
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
    };

    lazygit = {
      enable = true;
    };

    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
      ];
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      defaultKeymap = "viins";
      initContent = ''
        source $HOME/.zprofile
        export GOPATH="$HOME/go/"
        export PATH="$GOPATH:$HOME/.local/share/npm/bin:$HOME/.local/share/fnm:$HOME/.cargo/bin:$GOPATH/bin:$HOME/.local/bin:$PATH"
        export EDITOR="nvim"
        export VISUAL="nvim"
      '';
      shellAliases = {
        lzg = "lazygit";
        ls = "eza -lgh";
        dc = "docker compose";
        dcu = "docker compose up";
        dce = "docker compose exec";
        dcb = "docker compose build";
        dcd = "docker compose down";
        dcr = "docker compose run";
      };
      antidote = {
        enable = true;
        plugins = [
          "ohmyzsh/ohmyzsh path:plugins/fzf"
          "ohmyzsh/ohmyzsh path:plugins/zsh-interactive-cd"
          "ohmyzsh/ohmyzsh path:plugins/command-not-found"
          "zsh-users/zsh-autosuggestions"
          "zsh-users/zsh-syntax-highlighting"
          "zsh-users/zsh-completions"
        ];
      };
    };

    diff-so-fancy.enable = true;
  };
  home.packages = with pkgs;
    [
      tmux-sessionizer
      alejandra
      fzf
      direnv
      gnupg
      ripgrep
      fd
      eza
      glow
      bat
      delve
      httpie
      cmake
      gnumake
      rustup
      nodejs_20
      python3
      python312Packages.pip
      go
      fnm
      postgresql
      gemini-cli
      elixir
      htop
      fastfetch
      charm-freeze
      gum
    ]
    ++ [
      (pkgs.writeShellScriptBin "fzb" (lib.readFile ../../scripts/fzb.sh))
      (pkgs.writeShellScriptBin "rebnix" (lib.readFile ../../scripts/rebuild.sh))
      (pkgs.writeShellScriptBin "is_vim" (lib.readFile ../../scripts/is_vim.sh))
    ];

  programs = {
    home-manager.enable = true;
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/nvim";
  };

  home = {
    username = "alexp";
    homeDirectory = "/home/alexp";
    stateVersion = "24.05";
  };
}
