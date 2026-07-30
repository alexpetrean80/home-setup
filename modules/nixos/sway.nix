# System half of the sway desktop: compositor, session (greetd), portals,
# polkit. The actual window-manager config is home-manager's
# (modules/homemanager/sway.nix) — this only makes a sway session possible.
{pkgs, ...}: {
  programs.sway = {
    enable = true;
    # Wrap sway so GTK apps started from it get the right env (GDK_BACKEND,
    # portal-friendly XDG vars).
    wrapperFeatures.gtk = true;
    xwayland.enable = true; # discord and steam are X11 clients
  };

  # tuigreet on tty1 → sway. --remember-session means picking sway once sticks.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --cmd sway";
      user = "greeter";
    };
  };

  # Screen sharing / file pickers under wlroots. wlr portal handles screencast,
  # gtk portal handles the file chooser + settings.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = ["wlr" "gtk"];
  };

  security = {
    polkit.enable = true;
    # swaylock is installed per-user by home-manager, so NixOS has to publish
    # the PAM stack it authenticates against — without this, unlock fails.
    pam.services.swaylock = {};
  };

  # GTK app settings (theme, cursor) are read over dconf.
  programs.dconf.enable = true;

  # brightnessctl's udev rules let a `video` group member write
  # /sys/class/backlight without setuid.
  services.udev.packages = [pkgs.brightnessctl];

  # Trash, mounting removable media from file dialogs.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.sessionVariables = {
    # Electron (discord, Claude desktop) native wayland instead of xwayland.
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    # Java/SDL/QT wayland preference for the odd toolkit app.
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
