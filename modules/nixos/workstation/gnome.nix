{ pkgs, ... }: {
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-settings-daemon
  ] ++ (with pkgs.gnomeExtensions;
    [
      appindicator
      blur-my-shell
      caffeine
      gsconnect
    ]);
}
