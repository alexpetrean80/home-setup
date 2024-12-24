{ lib, ... }: {
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "go" ];
    userKeymaps = lib.importJSON ../../../dotfiles/zed/keymap.json;
    userSettings = lib.importJSON ../../../dotfiles/zed/settings.json;
  };
}
