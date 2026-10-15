# System half of the Plasma desktop: session, login screen, boot splash, fonts,
# all in Catppuccin Mocha/Blue. Per-user Plasma settings (global theme, cursors,
# icons, default terminal) are home-manager's, in modules/homemanager/kde.nix.
{
  pkgs,
  lib,
  ...
}: {
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-blue";
  };

  boot.plymouth = {
    enable = true;
    theme = "catppuccin-mocha";
    themePackages = [(pkgs.catppuccin-plymouth.override {variant = "mocha";})];
  };
  # Plymouth only gets a clean screen if the kernel and initrd keep quiet.
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = ["quiet" "splash"];

  # Catppuccin Mocha on the virtual consoles, in catppuccin/tty's slot order:
  # base red green yellow blue pink teal subtext1, then surface2 and the same
  # accents again with subtext0.
  console.colors = [
    "1e1e2e"
    "f38ba8"
    "a6e3a1"
    "f9e2af"
    "89b4fa"
    "f5c2e7"
    "94e2d5"
    "bac2de"
    "585b70"
    "f38ba8"
    "a6e3a1"
    "f9e2af"
    "89b4fa"
    "f5c2e7"
    "94e2d5"
    "a6adc8"
  ];

  environment.systemPackages = [
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      accent = "blue";
      font = "JetBrainsMono Nerd Font";
      fontSize = "11";
    })
  ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono # ghostty and the SDDM theme assume this
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      # Ahead of plasma6's Hack default.
      monospace = lib.mkBefore ["JetBrainsMono Nerd Font Mono"];
      emoji = ["Noto Color Emoji"];
    };
  };

  # Electron (vesktop) on native wayland instead of xwayland.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
