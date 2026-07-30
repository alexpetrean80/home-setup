# Everything around the compositor: notifications, lock/idle, tray helpers,
# GUI apps and the shared Catppuccin Mocha look. Linux-only — theseus imports
# it, the darwin host does not.
{
  inputs,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    discord
    # Zen (beta channel) from the community flake — same browser as the mac.
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    deezer-enhanced # electron wrapper; the mac runs the official Deezer app
    # Terminal WhatsApp (also does Telegram). First run pairs by QR:
    # `nchat` → scan from the phone. Config lives in ~/.config/nchat.
    nchat
    ghostty
    # wayland utility belt
    wl-clipboard
    grim # screenshots (bound to Print)
    slurp # region picker
    swappy # annotate a screenshot
    wf-recorder
    brightnessctl
    playerctl
    wdisplays # GUI output arrangement, service mode `d`
    pavucontrol
    libnotify # notify-send, for testing mako
    # media/viewers so xdg-open has something to hand off to
    imv
    mpv
    xdg-utils
  ];

  # Reuse the macOS ghostty dotfiles verbatim — same font, same catppuccin
  # light/dark pair — instead of a second source of truth in nix.
  xdg.configFile = {
    "ghostty/config".source = ../../dotfiles/ghostty/config;
    "ghostty/themes".source = ../../dotfiles/ghostty/themes;
  };

  # Notifications: the mako equivalent of macOS banners, Mocha-tinted.
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 11";
      background-color = "#1e1e2ef0";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      progress-color = "over #313244";
      border-size = 2;
      border-radius = 12;
      padding = "10,14";
      margin = "12";
      default-timeout = 5000;
      anchor = "top-right";
      layer = "overlay";
      max-visible = 4;
      icons = true;
      "urgency=low" = {
        border-color = "#45475a";
        text-color = "#a6adc8";
      };
      "urgency=critical" = {
        border-color = "#f38ba8";
        default-timeout = 0;
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      color = "1e1e2e";
      bs-hl-color = "f38ba8";
      key-hl-color = "a6e3a1";
      ring-color = "45475a";
      ring-ver-color = "89b4fa";
      ring-wrong-color = "f38ba8";
      inside-color = "1e1e2e";
      inside-ver-color = "1e1e2e";
      inside-wrong-color = "1e1e2e";
      line-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      text-color = "cdd6f4";
      text-ver-color = "89b4fa";
      text-wrong-color = "f38ba8";
      indicator-radius = 100;
      indicator-thickness = 8;
      indicator-caps-lock = true;
      show-failed-attempts = true;
      ignore-empty-password = true;
    };
  };

  # Lock at 5min, screen off at 6min, suspend at 15min; always lock before
  # sleep so a closed lid can't be reopened into a live session.
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${lib.getExe pkgs.swaylock} -f";
      }
      {
        timeout = 360;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      before-sleep = "${lib.getExe pkgs.swaylock} -f";
      lock = "${lib.getExe pkgs.swaylock} -f";
    };
  };

  # Tray: network + a polkit agent so pkexec prompts (fwupd, blueman) have a UI.
  services.network-manager-applet.enable = true;
  services.polkit-gnome.enable = true;

  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    theme.name = "Adwaita-dark";
    # GTK4/libadwaita ignores GTK3 themes; the dark preference below is what
    # actually applies there. Explicit null silences home-manager's
    # stateVersion-default warning.
    gtk4.theme = null;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # libadwaita apps and anything reading the freedesktop appearance setting.
  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # Export XDG_*_DIR so grim's ~/Pictures target and file dialogs agree.
    setSessionVariables = true;
  };

  # Zen/discord/ghostty all resolve `xdg-open` through the portal, which needs a
  # default browser to hand http(s) to. `zen-beta` is the binary (and desktop
  # entry) name the flake's default package installs.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "image/png" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "video/mp4" = "mpv.desktop";
    };
  };
}
