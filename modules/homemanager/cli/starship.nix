{lib, ...}: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ../../../dotfiles/starship.toml;
  };
}
