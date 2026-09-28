{...}: {
  imports = [
    ../../modules/nixos/core.nix
    ../../modules/nixos/wsl.nix
  ];

  # Windows names machines in caps and WSL inherits that name by default, so
  # keep it: this is also what `nixos-rebuild switch --flake .` matches against
  # (nixosConfigurations.THESEUS). Distinct from the bare-metal `theseus`
  # output in hosts/theseus, which is NixOS booted directly on the Latitude.
  networking.hostName = "THESEUS";

  system.stateVersion = "26.05";
}
