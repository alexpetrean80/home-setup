{ pkgs, ... }: {
  imports = [
    ./git.nix
    ./neovim.nix
    ./scripts.nix
    ./starship.nix
    ./tmux.nix
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    fzf
    gnupg
    ripgrep
    fd
    eza
    glow
    bat
    neovim
    neofetch
    nixd
    httpie
    cmake
    gnumake
    gcc
    rustup
    nodejs_20
    python3
    python312Packages.pip
    go
    fnm
    postgresql
    tmux-sessionizer
    elixir
    htop
    fastfetch
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
