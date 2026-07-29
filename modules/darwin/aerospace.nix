# AeroSpace: i3-style tiling WM. No SIP disable required — it emulates
# its own workspaces instead of touching native macOS Spaces.
# Needs Accessibility permission (TCC prompt on first launch) — not a
# security bypass, just a per-app grant you approve in System Settings.
{pkgs, ...}: {
  services.aerospace = {
    enable = true;
    settings = {
      # launchd owns the process; keep these at defaults (module asserts).
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      # Reclaim mouse to the focused monitor centre on switch.
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];

      # Launch the workspace apps at login. `open -a` is idempotent — it just
      # focuses an already-running app, so config reloads won't duplicate them.
      after-startup-command = [
        "exec-and-forget open -a 'Zen Browser'"
        "exec-and-forget open -a Deezer"
        "exec-and-forget open -a Linear"
        "exec-and-forget open -a Slack"
        "exec-and-forget open -a Claude"
      ];

      # Route each app to its home workspace whenever its window appears.
      # Ghostty is startup-only so later `alt-enter` terminals stay put.
      on-window-detected = [
        {
          "if".app-id = "app.zen-browser.zen";
          run = ["move-node-to-workspace 1"];
        }
        {
          "if".app-id = "com.deezer.deezer-desktop";
          run = ["move-node-to-workspace 2"];
        }
        {
          "if".app-id = "com.linear";
          run = ["move-node-to-workspace 4"];
        }
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = ["move-node-to-workspace 7"];
        }
        {
          "if".app-id = "com.anthropic.claudefordesktop";
          run = ["move-node-to-workspace 8"];
        }
        {
          "if" = {
            app-id = "com.mitchellh.ghostty";
            during-aerospace-startup = true;
          };
          run = ["move-node-to-workspace 3"];
        }
      ];

      # Drive the sketchybar workspace indicators. Absolute path: aerospace's
      # launchd PATH is the bare default and does not include the nix profile
      # bin, so a bare `sketchybar` here silently fails.
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.right = 8;
        outer.bottom = 8;
        # Per-monitor top gap to clear the floating sketchybar (bottom edge
        # ~40px from screen top: y_offset 8 + height 32) PLUS ~8-12px breathing
        # room so windows don't glue to the bar. outer.top is measured from
        # below the menu bar, so the built-in (taller notched menu bar) needs a
        # smaller number than externals for the same visual gap.
        # List = first matching monitor pattern wins; trailing int = default.
        # Tune these if the bar↔window gap looks off.
        outer.top = [{monitor.built-in = 22;} 48];
      };

      # Pin workspaces to monitors (externals-heavy). Patterns are
      # case-insensitive regex on the monitor name; "built-in" is a keyword.
      # When a monitor is absent (undocked), its workspaces fall back to the
      # main display automatically, then return on redock.
      workspace-to-monitor-force-assignment = {
        "1" = "built-in";
        "2" = "built-in";
        "3" = "ultragear";
        "4" = "ultragear";
        "5" = "ultragear";
        "6" = "ultragear";
        "7" = "dell";
        "8" = "dell";
        "9" = "dell";
      };

      mode.main.binding = {
        # app launchers
        alt-enter = "exec-and-forget open -na Ghostty";
        # Zen is Firefox-based: `open -na` hits the profile lock and just
        # raises an existing window (AeroSpace then yanks it to this display)
        # instead of spawning. Call the binary with --new-window so the running
        # instance opens a real new window. Path is stable across Zen updates.
        alt-shift-enter = "exec-and-forget /Applications/Zen.app/Contents/MacOS/zen --new-window";

        # focus (i3-style hjkl on alt/option)
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # move window
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # resize: quick nudges, or `alt-r` for a sticky resize mode (hjkl).
        alt-minus = "resize smart -50";
        alt-equal = "resize smart +50";
        alt-r = "mode resize";

        # layouts
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";
        alt-f = "fullscreen";
        alt-shift-space = "layout floating tiling";
        # equalize every split in the workspace back to even sizes
        alt-b = "balance-sizes";

        # close focused window; quit the app when it's the last window
        alt-q = "close --quit-if-last-window";

        # workspaces
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        # move focused window to workspace
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        # jump back to previous workspace
        alt-tab = "workspace-back-and-forth";

        # cross-monitor: focus + throw window (follows) to prev/next monitor
        alt-leftSquareBracket = "focus-monitor --wrap-around prev";
        alt-rightSquareBracket = "focus-monitor --wrap-around next";
        alt-shift-leftSquareBracket = "move-node-to-monitor --focus-follows-window --wrap-around prev";
        alt-shift-rightSquareBracket = "move-node-to-monitor --focus-follows-window --wrap-around next";

        alt-shift-c = "reload-config";

        # toggle the sketchybar keymap cheatsheet (⌥⇧/ = "?"). Sets the popup
        # directly — same one-liner as the icon's click_script. Absolute path:
        # aerospace's launchd PATH lacks the nix profile bin (same reason as
        # exec-on-workspace-change above).
        alt-shift-slash = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --set cheatsheet popup.drawing=toggle";

        # enter a one-shot service mode for less-common ops
        alt-shift-semicolon = "mode service";
      };

      mode.service.binding = {
        esc = ["reload-config" "mode main"];
        r = ["flatten-workspace-tree" "mode main"];
        f = ["layout floating tiling" "mode main"];
        backspace = ["close-all-windows-but-current" "mode main"];
      };

      # Sticky resize mode: `alt-r` enters, then hjkl resize without holding
      # any modifier; enter/esc return to main. Direction mirrors i3 — h/l on
      # width, j/k on height; -/= keep the smart nudge along parent axis.
      mode.resize.binding = {
        h = "resize width -50";
        l = "resize width +50";
        j = "resize height +50";
        k = "resize height -50";
        minus = "resize smart -50";
        equal = "resize smart +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}
