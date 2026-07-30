# Sway, configured to match the macOS AeroSpace setup (modules/darwin/
# aerospace.nix) key-for-key: Alt is the modifier, i3-style hjkl, 9 workspaces,
# sticky resize mode, one-shot service mode.
#
# Where sway and AeroSpace genuinely differ, the comment says so instead of
# faking parity:
#   - `resize smart` has no sway equivalent → alt -/= resize width.
#   - `balance-sizes` has no sway equivalent → alt+b is unbound.
#   - accordion → sway `stacking`.
#   - waybar owns an exclusive zone, so no per-monitor top gap is needed.
{
  inputs,
  pkgs,
  lib,
  ...
}: let
  mod = "Mod1"; # Alt, same as AeroSpace's `alt-`

  # Absolute store paths, not bare names: sway inherits greetd's minimal PATH,
  # which does not include the home-manager profile bin. Same trap the
  # aerospace module hits with sketchybar.
  ghostty = lib.getExe pkgs.ghostty;
  # Zen beta from the community flake; binary and app_id are both `zen-beta`.
  browser = lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  deezer = lib.getExe pkgs.deezer-enhanced;
  # WhatsApp lives in a terminal: a dedicated ghostty window running nchat.
  # `--class` sets the wayland app_id (GTK wants a dotted id), which is what
  # the workspace assignment below matches on.
  whatsapp = "${ghostty} --class=org.nchat.nchat --title=nchat -e ${lib.getExe pkgs.nchat}";
  wofi = lib.getExe pkgs.wofi;
  swaylock = lib.getExe pkgs.swaylock;
  brightnessctl = lib.getExe pkgs.brightnessctl;
  playerctl = lib.getExe pkgs.playerctl;
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  grim = lib.getExe pkgs.grim;
  slurp = lib.getExe pkgs.slurp;
  wlcopy = "${pkgs.wl-clipboard}/bin/wl-copy";

  inherit (import ./sway-scripts.nix {inherit pkgs lib;}) cheatsheet killOthers;
in {
  home.packages = [cheatsheet killOthers];

  # Tie every wayland user service (waybar, mako, swayidle, nm-applet, the
  # polkit agent) to sway's own target rather than the generic
  # graphical-session one, so they start with sway and stop when it exits.
  # sway.systemd.enable below defines and starts sway-session.target.
  wayland.systemd.target = "sway-session.target";

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    # Imports the wayland env into the systemd user session and starts
    # sway-session.target — that target is what waybar/mako/swayidle units
    # hang off, so they come up and go down with sway.
    systemd.enable = true;

    config = {
      modifier = mod;
      terminal = ghostty;
      menu = "${wofi} --show drun";

      # Titlebars are off, but swaynag and the mode indicator still draw text.
      fonts = {
        names = ["JetBrainsMono Nerd Font"];
        size = 11.0;
      };

      # Terminal's home workspace (AeroSpace pins Ghostty to 3).
      defaultWorkspace = "workspace number 3";
      workspaceLayout = "default";

      gaps = {
        inner = 8;
        outer = 4;
        smartGaps = false;
      };

      # JankyBorders parity: blue→lavender focus, dim surface1 for everything
      # else, so every window is framed but the focused one is unmistakable.
      window = {
        border = 3;
        titlebar = false;
        hideEdgeBorders = "none";
      };
      floating = {
        border = 3;
        titlebar = false;
        criteria = [
          {app_id = "pavucontrol";}
          {app_id = "blueman-manager";}
          {app_id = "nm-connection-editor";}
          {app_id = "wdisplays";}
          {app_id = "org.gnome.Calculator";}
          {title = "^Steam Settings$";}
          {title = "^Friends List$";}
          {window_role = "pop-up";}
          {window_role = "dialog";}
          {window_type = "dialog";}
        ];
      };

      colors = let
        base = "#1e1e2e";
        text = "#cdd6f4";
        blue = "#89b4fa";
        lavender = "#b4befe";
        surface1 = "#45475a";
        red = "#f38ba8";
      in {
        focused = {
          border = blue;
          background = base;
          childBorder = blue;
          indicator = lavender;
          text = text;
        };
        focusedInactive = {
          border = surface1;
          background = base;
          childBorder = surface1;
          indicator = surface1;
          text = text;
        };
        unfocused = {
          border = surface1;
          background = base;
          childBorder = surface1;
          indicator = surface1;
          text = text;
        };
        urgent = {
          border = red;
          background = base;
          childBorder = red;
          indicator = red;
          text = text;
        };
      };

      focus = {
        followMouse = false;
        newWindow = "smart";
        # AeroSpace's `on-focused-monitor-changed: move-mouse
        # monitor-lazy-center` — sway warps the pointer to the focused output.
        mouseWarping = "output";
      };

      # waybar runs as its own systemd user unit (see waybar.nix).
      bars = [];

      output = {
        # Latitude 5401 panel — no `mode` line, so sway takes the panel's
        # preferred mode (FHD on most SKUs, HD+ on the cheap one) instead of
        # erroring out on a hardcoded guess. `wdisplays` (alt+shift+; then d)
        # for externals; add entries here once you know the docked monitor
        # names from `swaymsg -t get_outputs`.
        "eDP-1" = {
          scale = "1";
          bg = "#1e1e2e solid_color";
        };
        "*".bg = "#1e1e2e solid_color";
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "us";
          repeat_delay = "300";
          repeat_rate = "40";
        };
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
          dwt = "enabled"; # disable-while-typing
          middle_emulation = "enabled";
          click_method = "clickfinger";
          scroll_factor = "0.4";
        };
      };

      # Route each app to its home workspace, mirroring AeroSpace's
      # on-window-detected — same slots as the mac: 1 browser, 2 music,
      # 3 terminal, 7 chat. Steam takes 5 (no mac counterpart) and the nchat
      # terminal takes 8. Plain ghostty is deliberately absent: `assign` would
      # yank every new terminal to 3, whereas AeroSpace only routes the startup
      # one. app_id matches wayland clients, class matches xwayland ones — for
      # the electron apps it is not worth guessing which, so match both.
      assigns = {
        "1" = [{app_id = "^zen-beta$";}];
        "2" = [{app_id = "(?i)deezer";} {class = "(?i)deezer";}];
        "5" = [{class = "^[Ss]team$";}];
        "7" = [{app_id = "discord";} {class = "discord";}];
        "8" = [{app_id = "^org\\.nchat\\.nchat$";}];
      };

      startup = [
        # Idempotent-ish: sway only runs these on config *load*, and `reload`
        # (alt+shift+c) does not re-run startup commands.
        {command = browser;}
        {command = ghostty;}
        {command = deezer;}
        {command = lib.getExe pkgs.discord;}
        {command = whatsapp;}
        # Steam is not autostarted — it is slow and grabs focus. alt+5 then
        # launch it from wofi.
      ];

      keybindings = {
        # ---- app launchers ----
        "${mod}+Return" = "exec ${ghostty}";
        "${mod}+Shift+Return" = "exec ${browser} --new-window";
        # Wox analogue. alt+space is Wox's macOS hotkey, kept identical.
        "${mod}+space" = "exec ${wofi} --show drun";
        "${mod}+d" = "exec ${wofi} --show drun";
        "${mod}+Shift+d" = "exec ${wofi} --show run";
        # Bring WhatsApp back if you closed it (lands on ws8 via `assigns`).
        "${mod}+Shift+w" = "exec ${whatsapp}";

        # ---- focus (i3-style hjkl) ----
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # ---- move window ----
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # ---- resize: quick nudges, or alt+r for sticky resize mode ----
        # AeroSpace's `resize smart` picks the parent axis; sway has no such
        # command, so these act on width (the common case) and the mode covers
        # both axes.
        "${mod}+minus" = "resize shrink width 50px";
        "${mod}+equal" = "resize grow width 50px";
        "${mod}+r" = "mode resize";

        # ---- layouts ----
        "${mod}+slash" = "layout toggle split";
        "${mod}+comma" = "layout toggle stacking tabbed split";
        "${mod}+f" = "fullscreen toggle";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+Ctrl+space" = "focus mode_toggle"; # jump between float and tile
        # NOTE: no alt+b — sway has no `balance-sizes` equivalent.

        # ---- close ----
        "${mod}+q" = "kill";

        # ---- workspaces ----
        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";

        "${mod}+Tab" = "workspace back_and_forth";

        # ---- cross-monitor: focus + throw window (focus follows it) ----
        # sway takes directions rather than prev/next, which is the same thing
        # on a left-right monitor row.
        "${mod}+bracketleft" = "focus output left";
        "${mod}+bracketright" = "focus output right";
        "${mod}+Shift+bracketleft" = "move container to output left";
        "${mod}+Shift+bracketright" = "move container to output right";

        "${mod}+Shift+c" = "reload";

        # keymap cheatsheet (alt+shift+/ = "?"). Bound twice on purpose: sway
        # matches the *translated* keysym, so shift+/ arrives as `question` on
        # a US layout — but not on every layout, so keep the literal spelling
        # too. Same for shift+; → `colon` below.
        "${mod}+Shift+slash" = "exec ${lib.getExe cheatsheet}";
        "${mod}+Shift+question" = "exec ${lib.getExe cheatsheet}";

        "${mod}+Shift+semicolon" = "mode service";
        "${mod}+Shift+colon" = "mode service";

        # ---- laptop keys (no macOS counterpart — the hardware has them) ----
        "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec ${brightnessctl} set 5%+";
        "XF86MonBrightnessDown" = "exec ${brightnessctl} set 5%-";
        "XF86AudioPlay" = "exec ${playerctl} play-pause";
        "XF86AudioNext" = "exec ${playerctl} next";
        "XF86AudioPrev" = "exec ${playerctl} previous";

        # ---- screenshots ----
        "Print" = "exec ${grim} -g \"$(${slurp})\" - | ${wlcopy}";
        "Shift+Print" = "exec ${grim} - | ${wlcopy}";
        "${mod}+Print" = "exec ${grim} -g \"$(${slurp})\" ~/Pictures/screenshot-$(${pkgs.coreutils}/bin/date +%Y%m%d-%H%M%S).png";
      };

      modes = {
        # Sticky resize: alt+r enters, hjkl resize with no modifier held,
        # enter/esc leave. Direction mirrors i3 — h/l width, j/k height.
        resize = {
          "h" = "resize shrink width 50px";
          "l" = "resize grow width 50px";
          "j" = "resize grow height 50px";
          "k" = "resize shrink height 50px";
          "minus" = "resize shrink width 50px";
          "equal" = "resize grow width 50px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };

        # One-shot service mode for less-common ops (alt+shift+;). `mode
        # default` comes FIRST in every chain: `exec` swallows the rest of the
        # line, so anything after it in the chain would never run.
        service = {
          "Escape" = "mode default; reload";
          "f" = "mode default; floating toggle";
          "BackSpace" = "mode default; exec ${lib.getExe killOthers}";
          "l" = "mode default; exec ${swaylock} -f";
          "d" = "mode default; exec ${lib.getExe pkgs.wdisplays}";
          "s" = "mode default; exec ${pkgs.systemd}/bin/systemctl suspend";
          "e" = "mode default; exec ${pkgs.sway}/bin/swaynag -t warning -m 'Exit sway?' -B 'Yes' '${pkgs.sway}/bin/swaymsg exit'";
          "Return" = "mode default";
        };
      };
    };

    extraConfig = ''
      # Steam's transient windows (notifications, screenshot manager) are
      # borderless X11 popups that tile badly.
      for_window [class="^[Ss]team$" title="^$"] floating enable, border none
      for_window [title="^Steam - Self Updater$"] floating enable
      # gamescope gets the whole screen to itself.
      for_window [app_id="^gamescope$"] fullscreen enable

      # Picture-in-picture and screen-share indicators float and stay visible.
      for_window [title="^Picture-in-Picture$"] floating enable, sticky enable
      for_window [title="Sharing Indicator"] floating enable, sticky enable

      # Hide the pointer after 5s of keyboard-only work.
      seat * hide_cursor 5000
    '';
  };
}
