{
  inputs,
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Repos/home-setup/dotfiles/nvim";
  };

  home.packages = with pkgs; [
    luajitPackages.luarocks
    lua-language-server
    nixd
    gopls
    sqls
    terraform-ls
    stylua
    goimports-reviser
    golines
  ];
}
