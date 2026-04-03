{pkgs, ...}: {
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

  nix.settings.experimental-features = ["nix-command" "flakes" "pipe-operators"];

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Bucharest";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  users.users = {
    alexp = {
      isNormalUser = true;
      description = "Alex Petrean";
      extraGroups = ["networkmanager" "wheel" "audio"];
      shell = pkgs.zsh;
    };
  };
}
