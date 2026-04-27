# Standalone NixOS module for RSI Launcher / Star Citizen
# Extracted from github:LovingMelody/nix-citizen and patched for nixpkgs 25.11
{ config, lib, pkgs, ... }:
let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    mkOverride
    optional
    types
    ;

  cfg = config.programs.rsi-launcher;

  optionSet = {
    enable = mkEnableOption "Enable rsi-launcher";
    launchCommand = mkOption {
      type = types.str;
      default = "%command%";
      description = "Edit the launch command. `%command%` is replaced by the base launch command";
    };
    wine = mkOption {
      type = types.package;
      default = pkgs.wine;
      description = "Wine runner to use if umu.enable is false";
    };
    gamescope = {
      enable = mkEnableOption "Enable Gamescope";
      args = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Args to pass to gamescope";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.gamescope;
        description = "Gamescope package";
      };
    };
    udevRules = mkEnableOption "Enable udev rules for joysticks" // { default = cfg.setLimits; };
    package = mkOption {
      type = types.package;
      default = pkgs.rsi-launcher;
      description = "RSI Launcher package";
    };
    umu = {
      enable = mkEnableOption "Enable umu launcher";
      proton = mkOption {
        type = types.str;
        default = "GE-Proton";
        description = "Proton version";
      };
    };
    disableEAC = mkEnableOption "Disable EasyAntiCheat" // { default = false; };
    location = mkOption {
      default = "$HOME/Games/rsi-launcher";
      type = types.str;
      description = "Path to install RSI Launcher";
    };
    preCommands = mkOption {
      default = "";
      type = types.str;
      description = "Commands to run before launching";
    };
    postCommands = mkOption {
      default = "";
      type = types.str;
      description = "Commands to run after launching";
    };
    setLimits = mkOption {
      type = types.bool;
      default = true;
      description = "Set vm.max_map_count and fs.file-max required by Star Citizen";
    };
    enableNTsync = mkOption {
      type = types.bool;
      default = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
      description = "Enable NTsync kernel module (requires kernel >= 6.14)";
    };
    enforceWaylandDrv = mkOption {
      type = types.bool;
      default = false;
      description = "Enforce Wayland driver";
    };
  };
in
{
  options.programs.rsi-launcher = optionSet;

  config = mkMerge [
    {
      assertions = [
        {
          assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14" || (!cfg.enableNTsync);
          message = "NTsync requires kernel >= 6.14";
        }
      ];
    }

    (mkIf cfg.enable {
      boot.kernel.sysctl = mkIf cfg.setLimits {
        "vm.max_map_count" = mkOverride 999 16777216;
        "fs.file-max" = mkOverride 999 524288;
      };
      services.udev.packages = optional cfg.udevRules pkgs.lug-helper;
      boot = {
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        kernelModules = [ "snd-aloop" ] ++ lib.optional cfg.enableNTsync "ntsync";
      };
      security.pam = mkIf cfg.setLimits {
        loginLimits = [
          { domain = "*"; type = "soft"; item = "nofile"; value = "16777216"; }
        ];
      };
      environment.systemPackages = [ cfg.package ];
    })
  ];
}
