{ ... }: {
  imports = [
    ../cli
    # ./kitty.nix
    # ./wezterm.nix
    ./ghostty.nix
    ./zed.nix
  ];
}
