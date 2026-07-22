{config, ...}: let
  repo = "${config.home.homeDirectory}/Repos/home-setup";
in {
  # Wox v2 keeps its settings in a sqlite db (~/.wox/wox-user/wox.db) which
  # doesn't version sensibly, so nix only manages the text config: themes and
  # script plugins. Settings sync via Wox's own encrypted cloud sync.
  #
  # mkOutOfStoreSymlink points at the mutable repo checkout (not /nix/store) so
  # Wox's in-app theme/script editing can write straight back to the repo.
  home.file = {
    ".wox/wox-user/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${repo}/dotfiles/wox/themes";
    ".wox/wox-user/plugins/scripts".source =
      config.lib.file.mkOutOfStoreSymlink "${repo}/dotfiles/wox/plugins/scripts";
  };
}
