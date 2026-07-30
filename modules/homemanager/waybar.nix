# Waybar, laid out like the macOS sketchybar (modules/darwin/sketchybar.nix):
# two polybar-style rounded "islands" on a transparent bar — workspaces + mode
# + focused window on the left, status stack on the right.
#
# Item order on the right matches sketchybar's visual order (which adds
# right-to-left): DND, network, memory, cpu, battery, weather, clock, keymap.
{
  pkgs,
  lib,
  ...
}: let
  # Nerd Font glyphs by codepoint. Literal private-use characters do not
  # survive copy/paste reliably (see dotfiles/sketchybar/plugins/colors.sh,
  # which builds them with printf for the same reason), so build them from JSON
  # \u escapes. All of these are BMP, i.e. Font Awesome range.
  glyph = cp: builtins.fromJSON ''"\u${cp}"'';

  icon = {
    firefox = glyph "f269"; # Zen is firefox-based; same glyph the mac uses
    music = glyph "f001"; # Deezer, same as sketchybar's WS_ICON_2
    gamepad = glyph "f11b";
    terminal = glyph "f120";
    discord = glyph "f392";
    whatsapp = glyph "f232";
    clock = glyph "f017";
    cpu = glyph "f2db"; # microchip
    memory = glyph "f1c0"; # database (fa-memory is absent from JetBrainsMono)
    wifi = glyph "f1eb";
    ethernet = glyph "f0e8";
    wifiOff = glyph "f05e";
    bell = glyph "f0f3";
    bellOff = glyph "f1f6";
    keyboard = glyph "f11c";
    bolt = glyph "f0e7";
    bat0 = glyph "f244";
    bat1 = glyph "f243";
    bat2 = glyph "f242";
    bat3 = glyph "f241";
    bat4 = glyph "f240";
  };

  weather = pkgs.writeShellApplication {
    name = "waybar-weather";
    runtimeInputs = [pkgs.curl pkgs.jq pkgs.coreutils];
    text = lib.readFile ../../dotfiles/waybar/weather.sh;
  };

  # Same derivation the alt+shift+/ binding uses (see sway-scripts.nix); the
  # absolute path matters because the systemd unit's PATH is not the shell's.
  inherit (import ./sway-scripts.nix {inherit pkgs lib;}) cheatsheet;
in {
  programs.waybar = {
    enable = true;
    # Target comes from wayland.systemd.target (sway-session.target, set in
    # sway.nix), so waybar comes up with sway and dies with it.
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      # Matches sketchybar's `margin=8 y_offset=8`: the bar floats.
      margin-top = 8;
      margin-left = 8;
      margin-right = 8;
      spacing = 4;

      modules-left = ["sway/workspaces" "sway/mode" "sway/window"];
      modules-right = [
        "idle_inhibitor"
        "network"
        "memory"
        "cpu"
        "battery"
        "custom/weather"
        "clock"
        "custom/cheatsheet"
        "tray"
      ];

      "sway/workspaces" = {
        disable-scroll = true;
        all-outputs = false;
        format = "{icon}";
        # Assigned workspaces show their app glyph, the rest keep their number —
        # same idea as spaces.sh. Slots match sway.nix's `assigns`.
        format-icons = {
          "1" = icon.firefox; # zen
          "2" = icon.music; # deezer
          "3" = icon.terminal;
          "4" = "4";
          "5" = icon.gamepad; # steam
          "6" = "6";
          "7" = icon.discord;
          "8" = icon.whatsapp; # nchat
          "9" = "9";
        };
        # Empty list = draw on every output, so all nine pills are always there
        # (sketchybar creates all nine and hides the empty ones).
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
          "6" = [];
          "7" = [];
          "8" = [];
          "9" = [];
        };
      };

      # resize / service mode indicator — no sketchybar counterpart, but sway's
      # sticky modes need one so you know why hjkl stopped moving focus.
      "sway/mode".format = "  {}  ";

      "sway/window" = {
        format = "{title}";
        max-length = 60;
        separate-outputs = true;
        rewrite = {
          "" = "—";
        };
      };

      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = icon.bellOff;
          deactivated = icon.bell;
        };
        tooltip-format-activated = "idle inhibited — screen stays on";
        tooltip-format-deactivated = "idle timers active";
      };

      network = {
        interval = 5;
        format-wifi = "${icon.wifi}  {signalStrength}%";
        format-ethernet = "${icon.ethernet}  {ipaddr}";
        format-disconnected = "${icon.wifiOff}  off";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}\n↓ {bandwidthDownBits}  ↑ {bandwidthUpBits}";
        tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}\n↓ {bandwidthDownBits}  ↑ {bandwidthUpBits}";
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      };

      memory = {
        interval = 15;
        format = "${icon.memory}  {percentage}%";
        tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
        states.critical = 90;
      };

      cpu = {
        interval = 5;
        format = "${icon.cpu}  {usage}%";
        tooltip = true;
        states.critical = 90;
      };

      battery = {
        interval = 30;
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
        format-charging = "${icon.bolt}  {capacity}%";
        format-plugged = "${icon.bolt}  {capacity}%";
        format-icons = [icon.bat0 icon.bat1 icon.bat2 icon.bat3 icon.bat4];
        tooltip-format = "{timeTo}  ({power:0.1f}W)";
      };

      "custom/weather" = {
        exec = lib.getExe weather;
        return-type = "json";
        interval = 1800;
        tooltip = true;
      };

      clock = {
        interval = 10;
        format = "${icon.clock}  {:%a %d %b  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          on-scroll = 1;
          format = {
            months = "<span color='#cba6f7'><b>{}</b></span>";
            days = "<span color='#cdd6f4'>{}</span>";
            weekdays = "<span color='#89b4fa'><b>{}</b></span>";
            today = "<span color='#a6e3a1'><b>{}</b></span>";
          };
        };
      };

      # Same role as the sketchybar cheatsheet icon: click it or press
      # alt+shift+/ — both run the same script.
      "custom/cheatsheet" = {
        format = icon.keyboard;
        tooltip = true;
        tooltip-format = "sway keymap (alt+shift+/)";
        on-click = lib.getExe cheatsheet;
      };

      tray = {
        spacing = 8;
        icon-size = 16;
      };
    };

    style = lib.readFile ../../dotfiles/waybar/style.css;
  };
}
