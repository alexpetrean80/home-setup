{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    zen-browser.url = "github:MarceColl/zen-browser-flake";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nix-darwin
    , nixos-wsl
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        daslaptop = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daslaptop/nixos.nix ];
        };
        dascomp = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/dascomp/nixos.nix ];
        };
        daswsl = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daswsl/nixos.nix ];
        };

        daswsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            ./hosts/daswsl/nixos.nix
          ];
        };
      };

      darwinConfigurations = {
        F59V2P7FXY = nix-darwin.lib.darwinSystem {
          modules = [ ./hosts/dasworkmac/darwin.nix ];
        };
      };

      homeConfigurations = {
        "alexp@dascomp" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/dascomp/homemanager.nix ];
        };
        "alexp@daslaptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daslaptop/homemanager.nix ];
        };
        "alexp@workMac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/dasworkmac/homemanager.nix ];
        };
        "alex@daswsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daswsl/homemanager.nix ];
        };
      };
    };
}