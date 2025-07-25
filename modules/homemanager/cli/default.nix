{pkgs, ...}: {
  imports = [
    ./git.nix
    ./neovim.nix
    ./scripts.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    alejandra
    fzf
    direnv
    gnupg
    ripgrep
    fd
    eza
    glow
    bat
    delve
    httpie
    cmake
    gnumake
    rustup
    nodejs_20
    python3
    python312Packages.pip
    go
    fnm
    postgresql
    elixir
    htop
    fastfetch
    charm-freeze
    gum
  ];

  programs = {
    home-manager.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    username = "alexp";
    homeDirectory = "/home/alexp";
    stateVersion = "24.05";
  };
}
