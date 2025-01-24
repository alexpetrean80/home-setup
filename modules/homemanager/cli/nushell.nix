{ ... }: {
  programs.nushell = {
    enable = true;
    shellAliases = {
      lzg = "lazygit";
    };

    configFile.source = ../../../dotfiles/config.nu;
  };
}
