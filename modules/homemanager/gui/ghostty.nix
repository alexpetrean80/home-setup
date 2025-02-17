{ config, ... }: {
  home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/ghostty";
}
