{pkgs, ...}: let
  # Formatters are referenced by absolute store path: `extraPackages` only
  # wraps the `zeditor` CLI, so a Zed launched from Spotlight/Dock has none of
  # the profile on PATH.
  styluaBin = "${pkgs.stylua}/bin/stylua";
  isortBin = "${pkgs.isort}/bin/isort";
  blackBin = "${pkgs.black}/bin/black";

  prettier = {formatter = "prettier";};

  # Mirrors the ts_ls inlay hint block in dotfiles/nvim/init.lua, in the
  # vtsls/VS Code shape Zed's TypeScript adapter expects.
  tsInlayHints = {
    parameterNames = {
      enabled = "all";
      suppressWhenArgumentMatchesName = false;
    };
    parameterTypes.enabled = true;
    variableTypes = {
      enabled = true;
      suppressWhenTypeMatchesName = false;
    };
    propertyDeclarationTypes.enabled = true;
    functionLikeReturnTypes.enabled = true;
    enumMemberValues.enabled = true;
  };
in {
  programs.zed-editor = {
    enable = true;

    # Declarative like the rest of the repo: settings.json/keymap.json are
    # store symlinks, so Zed cannot rewrite them behind nix's back. Changing a
    # setting from Zed's UI will fail — edit this file and rebuild instead.
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    # Languages nvim gets from treesitter/LSP but Zed does not ship in core.
    extensions = [
      "catppuccin"
      "nix"
      "terraform"
      "helm"
      "toml"
      "dockerfile"
      "make"
      "lua"
      "elixir"
      "ruby"
      "sql"
      "html"
      "graphql"
    ];

    extraPackages = with pkgs; [
      stylua
      isort
      black
      nodejs_20
      go
      gopls
      lua-language-server
      terraform-ls
      pyright
      ruff
    ];

    userSettings = {
      vim_mode = true;

      # Same font and catppuccin flavours as dotfiles/ghostty/config, and the
      # same follow-the-system light/dark switch.
      theme = {
        mode = "system";
        light = "Catppuccin Latte";
        dark = "Catppuccin Mocha";
      };
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 15;
      ui_font_size = 14;

      # nvim: number + relativenumber, scrolloff 10, sidescrolloff 8, wrap.
      relative_line_numbers = "enabled";
      vertical_scroll_margin = 10;
      horizontal_scroll_margin = 8;
      soft_wrap = "editor_width";
      cursor_blink = false;

      # nvim: clipboard=unnamedplus, ignorecase + smartcase, yank highlight.
      vim = {
        use_system_clipboard = "always";
        use_smartcase_find = true;
        highlight_on_yank_duration = 200;
      };
      use_smartcase_search = true;

      # conform.nvim formatted on save; inlay hints were enabled on LspAttach.
      format_on_save = "on";
      inlay_hints.enabled = true;

      # git-blame.nvim was opt-in per buffer (<leader>gm), not always drawn.
      git.inline_blame.enabled = false;

      # conform.nvim's formatters_by_ft, translated. Go/Ruby/Terraform are
      # left on "auto": their language server already runs gofmt+goimports /
      # rubocop / terraform fmt.
      languages = {
        Lua.formatter.external = {
          command = styluaBin;
          arguments = ["-"];
        };
        Python.formatter = [
          {
            external = {
              command = isortBin;
              arguments = ["-" "--quiet"];
            };
          }
          {
            external = {
              command = blackBin;
              arguments = ["-q" "-"];
            };
          }
        ];
        JavaScript = prettier;
        JSX = prettier;
        TypeScript = prettier;
        TSX = prettier;
        JSON = prettier;
        JSONC = prettier;
        CSS = prettier;
        HTML = prettier;
        YAML = prettier;
        Markdown = prettier;
        GraphQL = prettier;
      };

      # Same server tuning as the vim.lsp.config blocks in init.lua.
      lsp = {
        gopls.initialization_options.hints = {
          rangeVariableTypes = true;
          parameterNames = true;
          constantValues = true;
          assignVariableTypes = true;
          compositeLiteralFields = true;
          compositeLiteralTypes = true;
          functionTypeParameters = true;
        };
        pyright.settings.python.analysis = {
          typeCheckingMode = "basic";
          autoImportCompletions = true;
          diagnosticMode = "openFilesOnly";
        };
        "lua-language-server".settings.Lua.hint.enable = true;
        vtsls.settings = {
          typescript.inlayHints = tsInlayHints;
          javascript.inlayHints = tsInlayHints;
        };
        "yaml-language-server".settings.yaml = {
          validate = true;
          schemaStore.enable = true;
        };
      };
    };

    # Leader is space, same as vim.g.mapleader. Groups match which-key's:
    # b=buffers, g=git, d=debug, l=lsp, t=testing, a=AI, x=diagnostics.
    userKeymaps = [
      {
        context = "(vim_mode == normal || vim_mode == visual) && !menu";
        bindings = {
          # top level
          "space space" = "file_finder::Toggle"; # <leader><leader> files
          "space /" = "pane::DeploySearch"; # <leader>/ grep
          "space e" = "project_panel::ToggleFocus"; # <leader>e explorer
          "space \\" = "pane::SplitRight"; # <leader>\ vsplit
          "space -" = "pane::SplitDown";
          "space r" = "editor::Rename"; # <leader>r inc-rename
          "space z" = "workspace::ToggleCenteredLayout"; # <leader>z zen
          "space shift-t" = "terminal_panel::Toggle"; # <leader>T terminal

          # lsp
          "space l a" = "editor::ToggleCodeActions";
          "space l f" = "editor::Format";
          "space l shift-f" = "project_symbols::Toggle";
          "space l d" = "editor::GoToDefinition";
          "space l shift-d" = "editor::GoToDeclaration";
          "space l i" = "editor::GoToImplementation";
          "space l r" = "editor::FindAllReferences";
          "space l t" = "editor::GoToTypeDefinition";
          "space l o" = "outline::Toggle";
          "space l h" = "editor::ToggleInlayHints";

          # diagnostics
          "space x n" = "editor::GoToDiagnostic";
          "space x p" = "editor::GoToPreviousDiagnostic";
          "space x x" = "diagnostics::Deploy";
          "space x b" = "editor::ToggleInlineDiagnostics";

          # git
          "space g g" = "git_panel::ToggleFocus"; # closest thing to lazygit
          "space g d" = "git::Diff";
          "space g b" = "git::Branch";
          "space g m" = "editor::ToggleGitBlameInline";
          "space g shift-m" = "git::Blame";
          "space g w" = "editor::OpenPermalinkToLine";
          "space g y" = "editor::CopyPermalinkToLine";

          # buffers (Zed tabs)
          "space b b" = "tab_switcher::Toggle";
          "space b n" = "pane::ActivateNextItem";
          "space b p" = "pane::ActivatePreviousItem";
          "space b d" = "pane::CloseActiveItem";

          # debug
          "space d b" = "editor::ToggleBreakpoint";
          "space d s" = "debugger::Start";
          "space d c" = "debugger::Continue";
          "space d i" = "debugger::StepInto";
          "space d o" = "debugger::StepOver";
          "space d shift-o" = "debugger::StepOut";
          "space d t" = "debug_panel::ToggleFocus";

          # testing (Zed runnables stand in for neotest)
          "space t n" = "editor::SpawnNearestTask";
          "space t l" = "task::Rerun";
          "space t s" = "task::Spawn";

          # AI (Zed's agent panel; Claude Code attaches as an external agent)
          "space a c" = "agent::ToggleFocus";
          "space a n" = "agent::NewThread";
          "space a shift-c" = "agent::NewExternalAgentThread";
          "space a r" = "agent::OpenHistory";
          "space a m" = "agent::ToggleModelSelector";
          "space a d" = "agent::OpenAgentDiff";
          "space a a" = "agent::KeepAll";
          "space a q" = "agent::RejectAll";
        };
      }
      {
        context = "vim_mode == visual && !menu";
        bindings = {
          # nvim mapped these to <gv / >gv to keep the selection
          ">" = ["workspace::SendKeystrokes" "> g v"];
          "<" = ["workspace::SendKeystrokes" "< g v"];
          "space a s" = "agent::AddSelectionToThread";
        };
      }
    ];
  };
}
