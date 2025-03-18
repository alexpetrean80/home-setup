{ pkgs, ... }: {
  environment.systemPackages =
    (with pkgs; [
      slack
      pinentry_mac
      google-cloud-sdk
      kubernetes-helm
      aws-vault
      teleport
      terraform
      tilt
      confluent-cli
      jdk17
      jira-cli-go
    ])
    ++ (with pkgs.darwin; [
      CF
      cf-private
      Libc
      Security
    ]);

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ids.gids.nixbld = 350;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  programs.zsh.enable = true;
  system.stateVersion = 4;
}
