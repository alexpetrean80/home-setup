# JankyBorders: draws a border around the focused window (AeroSpace itself
# draws none). No SIP disable, no TCC permission — ax_focus stays off so it
# uses the fast window-server path instead of the Accessibility API.
_: {
  services.jankyborders = {
    enable = true;
    width = 4.0;
    hidpi = true;
    style = "round";
    order = "above";
    # Catppuccin Mocha: focused = blue→lavender gradient; unfocused = dim
    # surface1 outline, so the focused window is unmistakable but every
    # window is still framed.
    active_color = "gradient(top_left=0xff89b4fa,bottom_right=0xffb4befe)";
    inactive_color = "0xff45475a";
  };
}
