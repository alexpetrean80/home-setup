{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/nvim";
  };

  home.packages = with pkgs; [
    luajitPackages.luarocks
	lua-language-server
    nixd
	gopls
  ];
}
