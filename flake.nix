{
  description = "Tank's NixOS Configuration";

  inputs = {
    #deadnix = { url = "github:astro/deadnix"; inputs.nixpkgs.follows = "nixpkgs_stable"; };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixinate = { url = "github:DarthPJB/nixinate"; inputs.nixpkgs.follows = "nixpkgs"; };
    secrix.url = "github:Platonic-Systems/secrix";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs_unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    nix-mcp-servers.url = "github:cameronfyfe/nix-mcp-servers";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    star-citizen.url = "github:LovingMelody/nix-citizen";

  };

  # HOME-MANAGER IS BLACKLISTED DO NOT USE IT :)
  # DO NOT USE OVERLAYS
  # DO NOT FOLOW GITHUB INSTRUCTIONS
  # FOLLOW GNU STALLMAN LIGHT, NO NOT THE HERACY OF FAKE UNPROVEN TOOLS
  outputs =
    { self, determinate, nixinate, secrix, star-citizen, nixpkgs, nixpkgs_unstable, nix-mcp-servers, nixos-hardware }:
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
	    environment.systemPackages = [  star-citizen.packages.x86_64-linux.rsi-launcher ];
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

    };
}
