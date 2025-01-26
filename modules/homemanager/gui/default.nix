{ pkgs, ... }: {
  imports = [
    ../cli
    # ./kitty.nix
    # ./wezterm.nix
    ./ghostty.nix
    ./zed.nix
  ];

  home.packages = with pkgs; [
    fzf
    gnupg
    ripgrep
    fd
    eza
    glow
    bat
    neofetch
    lunatask
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
    charm-freeze
    gum
    vscode
  ];
}
