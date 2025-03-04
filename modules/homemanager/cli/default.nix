{ pkgs, ... }: {
  imports = [
    ./git.nix
    ./neovim.nix
    ./nushell.nix
    ./scripts.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    fzf
    direnv
    gnupg
    ripgrep
    fd
    eza
    clang
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
