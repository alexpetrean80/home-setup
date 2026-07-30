# Helper commands shared by the sway and waybar modules. Not a home-manager
# module — a plain function so both importers get the same store paths (the
# cheatsheet is bound to a key in sway AND to a click in waybar).
{
  pkgs,
  lib,
}: {
  # which-key style keymap popup — sway port of the sketchybar cheatsheet.
  cheatsheet = pkgs.writeShellApplication {
    name = "sway-cheatsheet";
    runtimeInputs = [pkgs.wofi];
    text = lib.readFile ../../scripts/sway-cheatsheet.sh;
  };

  # AeroSpace's service-mode `close-all-windows-but-current`.
  killOthers = pkgs.writeShellApplication {
    name = "sway-kill-others";
    runtimeInputs = [pkgs.sway pkgs.jq];
    text = lib.readFile ../../scripts/sway-kill-others.sh;
  };
}
