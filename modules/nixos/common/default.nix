{ pkgs, ... }: {
  imports = [
    ./locale.nix
    ./sound.nix
    ./users.nix
    ./xserver.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    sqlite
    zip
    unzip
    home-manager
    neovim
    git
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  nixpkgs.config.allowUnfree = true;
}
