{ config, lib, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://nix-citizen.cachix.org"
    "https://nix-gaming.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
  ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "tank";
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Denver";

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.openssh.enable = true;

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General.Enable = "Source,Media,Sink,Socket";
  };

  services.pipewire.enable = false;
  services.pulseaudio.enable = true;

  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "bluetooth" ];
    packages = with pkgs; [ tree ];
  };
  security.sudo.wheelNeedsPassword = false;

  programs.firefox.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    vim wget opencode tmate git gh
    discord mumble
    pavucontrol ffmpeg vlc
    vivaldi spotify
    lutris wine winetricks
    calibre mtpfs cabextract unzip magic-wormhole
    inputs.nix-citizen.packages.${pkgs.system}.star-citizen
  ];

  fileSystems."/home/tank/Games" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}