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

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          secrix.nixosModules.default
          determinate.nixosModules.default
          ./machines/laptop
          ./settings/base-system
          ./users/darthpjb.nix
          ./users/tank.nix
          {
	    secrix = 
	    { 
	      defaultEncryptKeys = {
	         John88 = [(builtins.readFile ./public-keys/JOHN_BARGMAN_ED_25519.pub)];
	         tank = [(builtins.readFile ./public-keys/tankles-user-desktop.pub)];
	         };
	# hostPubKey = (builtins.readFile ./public-keys/tankles-laptop.pub);  
	     };
            _module.args = {
              nixinate = {
                host = "100.75.110.25"; # The computer IP
                sshUser = "tankles";
                buildOn = "locals"; # valid args are "local" or "remote"
                substituteOnTarget = true; # if buildOn is "local" then it will substitute on the target, "-s"
                hermetic = false;
              };
              inherit self;
              unstable = import nixpkgs_unstable { 
	        system = "x86_64-linux"; 
	        config.allowUnfree = true; 
	      };
            };
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit self; };
        modules = [
          secrix.nixosModules.default
          determinate.nixosModules.default
          ./machines/desktop
          ./settings/base-system
          ./users/darthpjb.nix
          ./users/tank.nix
          {
	    secrix = 
	    { 
	      defaultEncryptKeys = {
	         John88 = [(builtins.readFile ./public-keys/JOHN_BARGMAN_ED_25519.pub)];
	         tank = [(builtins.readFile ./public-keys/tankles-user-desktop.pub)];
	         };
		 hostPubKey = (builtins.readFile ./public-keys/tankles-desktop.pub);  
		 };
            environment.systemPackages = [ star-citizen.packages.x86_64-linux.rsi-launcher ];
            _module.args = {
              nixinate = {
                host = "100.113.169.51"; # The computer IP
                sshUser = "tank";
                buildOn = "remote"; # valid args are "local" or "remote"
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
