{pkgs, lib, ...}: {
  imports = [
    /etc/nixos/hardware-configuration.nix

    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "daslaptop";

  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vpl-gpu-rt
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };

  services.thermald.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 70;
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  system.stateVersion = "23.11";
}
