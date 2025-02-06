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
    catppuccin-sddm
    dolphin
  ];
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-sddm";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
