{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  programs = {
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
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            # save/restore the visible scrollback of every pane, not just layout
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = inputs.minimal-tmux.packages.${pkgs.stdenv.hostPlatform.system}.default;
        }
        # continuum has to load *after* minimal-tmux-status: it appends its
        # periodic-save hook to status-right, and minimal-tmux-status
        # overwrites status-right wholesale when it loads. Reverse the order
        # and auto-save silently stops happening.
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
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
        # per-directory work identity: commits under ~/Repos/optura/
        # use alex.petrean@optura.ai from ~/.gitconfig.optura
        "includeIf \"gitdir:~/Repos/optura/\"" = {
          path = "~/.gitconfig.optura";
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
        # NixOS has no chezmoi-written .zprofile, so don't fail the shell there.
        [ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile"
        export GOPATH="$HOME/go/"
        export PATH="$GOPATH:$HOME/.local/share/npm/bin:$HOME/.local/share/fnm:$HOME/.cargo/bin:$GOPATH/bin:$HOME/.local/bin:$PATH"
        export EDITOR="nvim"
        export VISUAL="nvim"

        # auto-switch node version on cd
        eval "$(fnm env --use-on-cd)"
      '';
      shellAliases = {
        lzg = "lazygit";
        ls = "eza -lgh --icons";
        lt = "eza --tree --level=2 --long --icons --git";
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

  # Bring the tmux server up at login so sessions survive a reboot: starting
  # the server sources tmux.conf, continuum sees a fresh server and replays the
  # newest resurrect save. The throwaway session "0" created here is killed by
  # resurrect once it has restored the real ones (handle_session_0).
  launchd.agents = lib.optionalAttrs pkgs.stdenv.isDarwin {
    tmux = {
      enable = true;
      config = {
        ProgramArguments = ["${pkgs.tmux}/bin/tmux" "new-session" "-d"];
        RunAtLoad = true;
        # tmux daemonises, so the job's main process exits immediately; without
        # this launchd reaps the server along with it.
        AbandonProcessGroup = true;
        EnvironmentVariables = {
          # launchd hands out a bare PATH. Restored panes re-exec their program
          # (nvim, ...) with the server's environment, so it needs the profiles.
          PATH = "/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };
  };

  systemd.user.services = lib.optionalAttrs pkgs.stdenv.isLinux {
    tmux = {
      Unit.Description = "tmux server, restored from the last continuum save";
      Service = {
        Type = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
        # take a final save on logout/shutdown instead of losing up to
        # @continuum-save-interval minutes of layout changes.
        ExecStop = [
          "-${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"
          "${pkgs.tmux}/bin/tmux kill-server"
        ];
        Environment = ["PATH=/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin"];
      };
      Install.WantedBy = ["default.target"];
    };
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
      (python3.withPackages (ps: with ps; [pip debugpy]))
      go
      fnm
      postgresql
      gemini-cli
      elixir
      htop
      fastfetch
      charm-freeze
      gum
      # optura repo tooling
      kubectl
      trivy
      uv
      argocd
      kubeseal
      yq-go
      k3d
      kind
      kustomize
      awscli2
      (azure-cli.withExtensions [azure-cli-extensions.resource-graph])
      regclient # regctl, regsync, regbot
      # migrated off homebrew
      just
      k9s
      lazydocker
      cloc
      pgcli
      chezmoi
      stylua
      terraform
      kubernetes-helm
      tilt
      teleport
      stow
      # nvim binary; config lives in dotfiles/nvim
      neovim
      # nvim LSP servers (replaces mason)
      clang-tools # clangd
      gopls
      helm-ls
      lua-language-server
      marksman
      pyright
      ruby-lsp
      ruff
      sqls
      terraform-ls
      tflint
      typescript-language-server
      vscode-langservers-extracted # jsonls, eslint
      vtsls
      yaml-language-server
      # nvim formatters/linters (replaces mason-tool-installer)
      black
      eslint_d
      golangci-lint
      golines
      gotools # goimports
      isort
      prettier
      prettierd
      rubocop
    ]
    ++ [
      (pkgs.writeShellScriptBin "fzb" (lib.readFile ../../scripts/fzb.sh))
      (pkgs.writeShellScriptBin "rebnix" (lib.readFile ../../scripts/rebuild.sh))
      (pkgs.writeShellScriptBin "is_vim" (lib.readFile ../../scripts/is_vim.sh))
    ];

  programs = {
    home-manager.enable = true;
  };

  home = {
    username = "alexp";
    homeDirectory = "/home/alexp";
    stateVersion = "24.05";
  };
}
