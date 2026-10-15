# Per-user half of the Plasma desktop on theseus: GUI apps, plus Catppuccin
# Mocha/Blue across Plasma, Discord and the terminal. The session, SDDM and
# fonts are system-side, in modules/nixos/kde.nix.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.plasma-manager.homeModules.plasma-manager];

  home.packages = with pkgs; [
    (catppuccin-kde.override {
      flavour = ["mocha"];
      accents = ["blue"];
    })
    catppuccin-cursors.mochaBlue
    (catppuccin-papirus-folders.override {
      flavor = "mocha";
      accent = "blue";
    })
    ghostty
    # Zen (beta channel) from the community flake — same browser as the mac.
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    # Free edition: no H.264/H.265 decode or AAC on Linux, so transcode
    # footage to DNxHR/ProRes first. GPU work goes through OpenCL, which the
    # UHD 630 gets from the legacy compute runtime (hosts/theseus/nixos.nix).
    davinci-resolve
    mpv
    wl-clipboard
  ];

  # Not overrideConfig: System Settings stays usable, and these get re-applied
  # on each activation.
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "Catppuccin-Mocha-Blue";
      colorScheme = "CatppuccinMochaBlue";
      iconTheme = "Papirus-Dark";
      # The global theme points at Catppuccin cursors it would download itself
      # outside nix; use the nixpkgs build instead.
      cursor = {
        theme = "catppuccin-mocha-blue-cursors";
        size = 24;
      };
    };
    powerdevil = {
      AC.powerProfile = "performance";
      battery.powerProfile = "powerSaving";
    };
    fonts.fixedWidth = {
      family = "JetBrainsMono Nerd Font";
      pointSize = 11;
    };
    # Dolphin's "Open Terminal" and anything else that asks KDE for one.
    configFile.kdeglobals.General = {
      TerminalApplication = "ghostty";
      TerminalService = "com.mitchellh.ghostty.desktop";
    };
  };

  # Reuse the macOS ghostty dotfiles verbatim — same font, same catppuccin
  # light/dark pair — instead of a second source of truth in nix.
  xdg.configFile = {
    "ghostty/config".source = ../../dotfiles/ghostty/config;
    "ghostty/themes".source = ../../dotfiles/ghostty/themes;
  };

  # Discord through Vesktop: the official client has no theming without a
  # client mod anyway, and Vesktop ships Vencord plus working wayland
  # screenshare. Settings stay mutable so the app can keep writing them; the
  # declared values win on each activation.
  programs.vesktop = {
    enable = true;
    mutableSettings = true;
    vencord = {
      mutableSettings = true;
      themes.catppuccin-mocha-blue = ''
        @import url("https://catppuccin.github.io/discord/dist/catppuccin-mocha-blue.theme.css");
      '';
      settings.enabledThemes = ["catppuccin-mocha-blue.css"];
    };
  };

  # WhatsApp Web in a Qt wrapper, so it follows the Plasma color scheme.
  programs.zapzap.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
  };

  # `zen-beta` is the binary (and desktop entry) name the flake's default
  # package installs.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "video/mp4" = "mpv.desktop";
    };
  };
}
