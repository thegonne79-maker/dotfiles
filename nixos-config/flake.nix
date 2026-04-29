{
  description = "Tank's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = inputs: {
    nixosConfigurations.desktop = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { 
        inherit inputs;
        unstable = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
      };
      modules = [
        ../nixos/configuration.nix
      ];
    };

    homeConfigurations.desktop = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../nixos/home.nix
      ];
    };
  };
}