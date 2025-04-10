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
    gcc
    zip
    unzip
    home-manager
    dotnet-sdk_9
    dotnet-runtime_9
    dotnet-aspnetcore_9
    neovim
    git
		inotify-tools
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];

  nixpkgs.config.allowUnfree = true;
}
