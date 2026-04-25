{
  description = "Tank's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, nixpkgs, home-manager, nix-citizen, nix-gaming, ... }: {
    nixosConfigurations.tank = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };

    homeConfigurations.tank = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home.nix
      ];
    };
  };
}