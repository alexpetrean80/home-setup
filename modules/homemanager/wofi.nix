# wofi = the Wox analogue on wayland: alt+space, type, enter.
#
# Wox itself keeps settings in a sqlite db and only its theme is version
# controlled (see wox.nix); wofi is plain config + CSS, so both live here and
# the CSS is a direct port of dotfiles/wox/themes/<uuid>.json.
{lib, ...}: {
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      mode = "drun";
      prompt = "";
      # Centred, roughly Wox-shaped.
      width = "38%";
      height = "42%";
      location = "center";
      lines = 9;
      columns = 1;
      allow_markup = true;
      allow_images = true;
      image_size = 28;
      insensitive = true;
      no_actions = true;
      gtk_dark = true;
      hide_scroll = true;
      # Rank by use, like Wox does.
      sort_order = "default";
      term = "ghostty";
      # Vim-ish: ctrl-j/k move, esc closes.
      key_up = "Up,Control_L-k";
      key_down = "Down,Control_L-j";
    };
    style = lib.readFile ../../dotfiles/wofi/style.css;
  };
}
