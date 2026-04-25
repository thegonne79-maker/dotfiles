{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  programs.home-manager.enable = true;

  home.stateVersion = "25.11";
}