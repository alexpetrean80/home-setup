{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    ghostty.url = "github:ghostty-org/ghostty";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    minimal-tmux = {
      url = "github:niksingh710/minimal-tmux-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    , home-manager
    , ghostty
    , hyprpanel
    , minimal-tmux
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        daslaptop = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            ./hosts/daslaptop/nixos.nix
            {
              environment.systemPackages = [
                ghostty.packages.x86_64-linux.default
                hyprpanel.packages.x86_64-linux.default
              ];
            }
          ];

        };
        dascomp = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/dascomp/nixos.nix
            {
              environment.systemPackages = [
                ghostty.packages.x86_64-linux.default
                hyprpanel.packages.x86_64-linux.default
              ];
            }
          ];
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
          modules = [ ./hosts/dascomp/homemanager.nix 
						{
# tmux config
programs.tmux.plugins = [
  { plugin = inputs.minimal-tmux.packages.${nixpkgs.legacyPackages.x86_64-linux.system}.default; }
];
						}
					];
        };
        "alexp@daslaptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daslaptop/homemanager.nix

						{
# tmux config
programs.tmux.plugins = [
  { plugin = inputs.minimal-tmux.packages.${nixpkgs.legacyPackages.x86_64-linux.system}.default; }
];
						}
					];
        };
        "alexp@F59V2P7FXY" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/dasworkmac/homemanager.nix

						{
# tmux config
programs.tmux.plugins = [
  { plugin = inputs.minimal-tmux.packages.${nixpkgs.legacyPackages.aarch64-darwin.system}.default; }
];
						}
					];
        };
        "alex@daswsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/daswsl/homemanager.nix ];
        };
      };
    };
}
