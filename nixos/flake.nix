{
  description = "Tank's NixOS Configuration";

  inputs = {
    #deadnix = { url = "github:astro/deadnix"; inputs.nixpkgs.follows = "nixpkgs_stable"; };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixinate = { url = "github:DarthPJB/nixinate"; inputs.nixpkgs.follows = "nixpkgs"; };
    secrix.url = "github:Platonic-Systems/secrix";
    #   secure_pkgs.url = "https://flakehub.com/f/DeterminateSystems/secure/0";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs_unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    #  parsecgaming.url = "github:DarthPJB/parsec-gaming-nix";
    nix-mcp-servers.url = "github:cameronfyfe/nix-mcp-servers";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  # HOME-MANAGER IS BLACKLISTED DO NOT USE IT :)

  outputs =
    { self, determinate, nixinate, secrix, nixpkgs, nixpkgs_unstable, nix-mcp-servers, nixos-hardware, nix-citizen, nix-gaming }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;
      system = "x86_64-linux"; # x86 only, do not use forall systems.
    in
    {
      formatter."${system}" = pkgs.nixpkgs-fmt;
      apps."${system}" = { secrix = secrix.secrix self; } // (nixinate.lib.genDeploy.x86_64-linux self);

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          secrix.nixosModules.default
          determinate.nixosModules.default
          ./configuration.nix
          ./penis.nix
          {
            _module.args = {
              nixinate = {
                host = "192.168.88.0"; # The computer IP
                sshUser = "tankles-or-something";
                buildOn = "local"; # valid args are "local" or "remote"
                substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
                hermetic = false;
              };
              inherit self;
              unstable = import nixpkgs_unstable { system = "x86_64-linux"; config.allowUnfree = true; };
            };
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };

      #    homeConfigurations.tank = inputs.home-manager.lib.homeManagerConfiguration {
      #      pkgs = import inputs.nixpkgs {
      #        system = "x86_64-linux";
      #        config.allowUnfree = true;
      #      };
      #      extraSpecialArgs = { inherit inputs; };
      #      modules = [
      #        ./home.nix
      #      ];
      #    };
    };
}
