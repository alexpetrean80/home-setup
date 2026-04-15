{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    slack
    bitwarden-desktop
    pinentry_mac
    nerd-fonts.jetbrains-mono
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  ids.gids.nixbld = 350;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  programs.zsh.enable = true;
  system.stateVersion = 4;
}
