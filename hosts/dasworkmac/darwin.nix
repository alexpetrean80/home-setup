{ pkgs, ... }: {
  environment.systemPackages =
    (with pkgs; [
      slack
      pinentry_mac
      google-cloud-sdk
      kubernetes-helm
      aws-vault
      snyk
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

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  programs.zsh.enable = true;
  system.stateVersion = 4;
}
