{ ... }: {
  imports = [
    /etc/nixos/hardware-configuration.nix

    ../../../modules/nixos/workstation
  ];

  hardware.    graphics = {
    extraPackages = with pkgs; [
      intel-media-sdk
      vpl-gpu-rt
      intel-media-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  networking.hostName = "daslaptop";

  system.stateVersion = "23.11";
}
