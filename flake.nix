{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix = {
      url = "github:musnix/musnix";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    musnix,
    catppuccin,
    ...
  } @ inputs: let
    inherit (self) outputs;

    mkNixosHost = hostname: system: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs; };
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/${hostname}/nixos.nix
        musnix.nixosModules.musnix
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs outputs; };
          home-manager.users.alexp = import ./hosts/${hostname}/homemanager.nix;
        }
      ];
    };

    mkDarwinHost = hostname: system: nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs outputs; };
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/${hostname}/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs outputs; };
          home-manager.users.alexp = import ./hosts/${hostname}/homemanager.nix;
        }
      ];
    };
  in {
    nixosConfigurations = {
      daslaptop = mkNixosHost "daslaptop" "x86_64-linux";
    };

    darwinConfigurations = {
      F59V2P7FXY = mkDarwinHost "dasworkmac" "aarch64-darwin";
    };
  };
}