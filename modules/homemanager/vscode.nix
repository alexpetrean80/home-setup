{pkgs, ...}: let
  # Mirrors the ts_ls inlay hint block in dotfiles/nvim/init.lua (and the
  # vtsls block in zed.nix), flattened into VS Code's dotted setting keys.
  tsInlayHints = lang: {
    "${lang}.inlayHints.parameterNames.enabled" = "all";
    "${lang}.inlayHints.parameterNames.suppressWhenArgumentMatchesName" = false;
    "${lang}.inlayHints.parameterTypes.enabled" = true;
    "${lang}.inlayHints.variableTypes.enabled" = true;
    "${lang}.inlayHints.variableTypes.suppressWhenTypeMatchesName" = false;
    "${lang}.inlayHints.propertyDeclarationTypes.enabled" = true;
    "${lang}.inlayHints.functionLikeReturnTypes.enabled" = true;
    "${lang}.inlayHints.enumMemberValues.enabled" = true;
  };

  prettier = {"editor.defaultFormatter" = "esbenp.prettier-vscode";};
in {
  programs.vscode = {
    enable = true;

    # Nix-pinned extensions are linked into ~/.vscode/extensions; the dir stays
    # mutable so one-off marketplace installs (aikido) keep working next to
    # them. settings.json itself is a store symlink, same as zed.nix: changing
    # a setting from the UI fails — edit here and rebuild.
    profiles.default = {
      # The binary comes from nixpkgs, so the in-app updater has nothing to do.
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        vscodevim.vim
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        # Same agent zed.nix attaches over ACP; auth still comes from ~/.claude.
        anthropic.claude-code
        # Languages nvim gets from treesitter/LSP — the zed.nix extension list.
        jnoortheen.nix-ide
        hashicorp.terraform
        tim-koehler.helm-intellisense
        tamasfe.even-better-toml
        ms-azuretools.vscode-docker
        sumneko.lua
        elixir-lsp.vscode-elixir-ls
        shopify.ruby-lsp
        graphql.vscode-graphql-syntax
        golang.go
        ms-python.python
        ms-pyright.pyright
        charliermarsh.ruff
        redhat.vscode-yaml
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];

      userSettings =
        {
          # Same font and catppuccin flavours as dotfiles/ghostty/config and
          # zed.nix, following the system light/dark switch.
          "window.autoDetectColorScheme" = true;
          "workbench.preferredLightColorTheme" = "Catppuccin Latte";
          "workbench.preferredDarkColorTheme" = "Catppuccin Mocha";
          "workbench.iconTheme" = "catppuccin-mocha";
          "editor.fontFamily" = "JetBrainsMono Nerd Font";
          "editor.fontSize" = 16;
          "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
          "terminal.integrated.fontSize" = 16;

          # nvim: relativenumber, scrolloff 10, wrap, no cursor blink.
          "editor.lineNumbers" = "relative";
          "editor.cursorSurroundingLines" = 10;
          "editor.wordWrap" = "on";
          "editor.cursorBlinking" = "solid";
          "editor.minimap.enabled" = false;

          # nvim: mapleader = space, clipboard=unnamedplus, ignorecase +
          # smartcase, yank highlight.
          "vim.leader" = "<space>";
          "vim.useSystemClipboard" = true;
          "vim.ignorecase" = true;
          "vim.smartcase" = true;
          "vim.hlsearch" = true;
          "vim.highlightedyank.enable" = true;
          "vim.highlightedyank.duration" = 200;

          # conform.nvim formatted on save; inlay hints were enabled on
          # LspAttach.
          "editor.formatOnSave" = true;
          "editor.inlayHints.enabled" = "on";

          # conform.nvim's formatters_by_ft, translated. Go/Ruby/Terraform
          # format through their own extension (gofmt+goimports / rubocop /
          # terraform fmt). Lua uses sumneko's built-in formatter; ruff stands
          # in for isort+black (black-compatible, organizeImports = isort).
          "[nix]" = {"editor.defaultFormatter" = "jnoortheen.nix-ide";};
          "[go]" = {"editor.defaultFormatter" = "golang.go";};
          "[terraform]" = {"editor.defaultFormatter" = "hashicorp.terraform";};
          "[ruby]" = {"editor.defaultFormatter" = "Shopify.ruby-lsp";};
          "[lua]" = {"editor.defaultFormatter" = "sumneko.lua";};
          "[python]" = {
            "editor.defaultFormatter" = "charliermarsh.ruff";
            "editor.codeActionsOnSave"."source.organizeImports" = "explicit";
          };
          "[javascript]" = prettier;
          "[javascriptreact]" = prettier;
          "[typescript]" = prettier;
          "[typescriptreact]" = prettier;
          "[json]" = prettier;
          "[jsonc]" = prettier;
          "[css]" = prettier;
          "[html]" = prettier;
          "[yaml]" = prettier;
          "[markdown]" = prettier;
          "[graphql]" = prettier;

          # Absolute store path: a VS Code launched from Spotlight/Dock has none
          # of the profile on PATH (same reason zed.nix pins its formatters).
          "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";

          # Same server tuning as the vim.lsp.config blocks in init.lua.
          "gopls" = {
            "ui.inlayhint.hints" = {
              rangeVariableTypes = true;
              parameterNames = true;
              constantValues = true;
              assignVariableTypes = true;
              compositeLiteralFields = true;
              compositeLiteralTypes = true;
              functionTypeParameters = true;
            };
          };
          "python.analysis.typeCheckingMode" = "basic";
          "python.analysis.autoImportCompletions" = true;
          "python.analysis.diagnosticMode" = "openFilesOnly";
          "Lua.hint.enable" = true;
          "yaml.validate" = true;
          "yaml.schemaStore.enable" = true;
        }
        // tsInlayHints "typescript"
        // tsInlayHints "javascript";
    };
  };
}
