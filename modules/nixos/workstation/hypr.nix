{ pkgs, ... }: {
  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    hyprls
    rofi
    hyprpaper
    hyprlock
    hyprpicker
  ];
  services.displayManager.sddm.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
