# SketchyBar status bar, Catppuccin Mocha (matches ghostty dark + starship).
# Needs no special permissions and no SIP disable.
{pkgs, ...}: let
  # The module renders `config` to a single store file, so the usual
  # $CONFIG_DIR/plugins layout does not exist. Build the plugin scripts
  # into their own store dir and reference them by absolute path.
  plugins = pkgs.runCommand "sketchybar-plugins" {} ''
    mkdir -p $out
    cp -r ${../../dotfiles/sketchybar/plugins}/. $out/
    chmod +x $out/*.sh
  '';
in {
  services.sketchybar = {
    enable = true;
    # aerospace CLI is used by the workspace plugin + click scripts.
    extraPackages = [pkgs.aerospace];
    config =
      ''
        #!/usr/bin/env bash
        export PLUGIN_DIR=${plugins}
      ''
      + builtins.readFile ../../dotfiles/sketchybar/sketchybarrc;
  };
}
