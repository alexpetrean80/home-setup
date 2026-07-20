{pkgs, ...}: {
  imports = [
    ../../modules/darwin/aerospace.nix
    ../../modules/darwin/sketchybar.nix
    ../../modules/darwin/borders.nix
  ];

  environment.systemPackages = with pkgs; [
    slack
    bitwarden-desktop
    ghostty-bin
    meetingbar
    notion-app
    alt-tab-macos
    pinentry_mac
    nerd-fonts.jetbrains-mono
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Nix is installed and managed by Determinate Nix, which owns
  # /etc/nix/nix.conf and the daemon. nix-darwin must not manage them.
  # Put nix.conf tweaks in /etc/nix/nix.custom.conf instead.
  nix.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  programs.zsh.enable = true;
  # User-level launchd agents (aerospace, sketchybar) attach to this user.
  system.primaryUser = "alexp";
  system.stateVersion = 4;
}
