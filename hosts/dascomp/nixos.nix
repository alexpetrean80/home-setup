{ pkgs, ... }: {
  imports = [
    /etc/nixos/hardware-configuration.nix

    ../../modules/nixos/workstation
  ];

  networking.hostName = "dascomp";

  boot = {
    kernelPackages = pkgs.linuxPackages_6_6;
    initrd.kernelModules = [ "amdgpu" ];
    kernelParams = [
      "amdgpu.sg_display=0"
    ];
  };

  services.xserver.videoDrivers = [ "modesetting" ];

  environment.variables.GSK_RENDERER = "gl";

  hardware.graphics = {
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  system.stateVersion = "23.11";
}
