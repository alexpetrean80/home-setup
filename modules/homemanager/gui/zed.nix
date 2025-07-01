{
  config,
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs; [zed-editor];
    file.".config/zed" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/zed";
    };
  };
}
