{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Intel CPU/GPU + laptop defaults for theseus (Dell Latitude 5401).
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # Zen is not in nixpkgs; upstream community flake tracks the beta channel.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;

    mkDarwinHost = hostname: system:
      nix-darwin.lib.darwinSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {nixpkgs.hostPlatform = system;}
          ./hosts/${hostname}/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # back up pre-existing (chezmoi-written) files instead of
            # aborting when home-manager takes over a path
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.alexp = import ./hosts/${hostname}/homemanager.nix;
          }
        ];
      };

    # Same shape as mkDarwinHost — home-manager rides along inside the system
    # config, so one `nixos-rebuild switch` applies both halves.
    mkNixosHost = hostname: system:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {nixpkgs.hostPlatform = system;}
          ./hosts/${hostname}/nixos.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = {inherit inputs outputs;};
            home-manager.users.alexp = import ./hosts/${hostname}/homemanager.nix;
          }
        ];
      };
  in {
    darwinConfigurations = {
      Alexs-MacBook-Pro = mkDarwinHost "dasworkmac" "aarch64-darwin";
    };

    nixosConfigurations = {
      theseus = mkNixosHost "theseus" "x86_64-linux";
    };
  };
}
