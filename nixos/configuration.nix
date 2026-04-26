{ config, lib, pkgs, inputs, ... }:

{

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # IMPORTS
  # ═══════════════════════════════════════════════════════════════════════════════
  imports = [ ./hardware-configuration.nix ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://nix-citizen.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = [
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════════════════
  networking.hostName = "tank";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # LOCALIZATION
  # ═══════════════════════════════════════════════════════════════════════════════
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Denver";

  # ═══════════════════════════════════════════════════════════════════════════════
  # DESKTOP
  # ═══════════════════════════════════════════════════════════════════════════════
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.openssh.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # GRAPHICS (NVIDIA)
  # ═══════════════════════════════���═══════════════════════════════════════════════
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.Enable = "Source,Media,Sink,Socket";

  # ═══════════════════════════════════════════════════════════════════════════════
  # AUDIO (PulseAudio)
  # ═══════════════════════════════════════════════════════════════════════════════
  services.pipewire.enable = false;
  services.pulseaudio.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # GAMING
  # ═══════════════════════════════════════════════════════════════════════════════
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # USER
  # ═══════════════════════════════════════════════════════════════════════════════
  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "bluetooth" ];
    packages = with pkgs; [ tree ];
  };

  # ═══════════════════════════════════════════════════════════════════════════════════
  # SYSTEM PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [

    # ── Base Utilities ─────────────────────────────────────────────────────────────
    vim
    wget
    curl
    git
    htop
    btop
    eza
    fd
    ripgrep
    fzf
    bat
unzip
    gzip
    bzip2
    xz
    p7zip
    cabextract
    mediainfo
    tmate

# ── Dev Tools ───────────────────────────────────────────────────────────
    vscode
    nodejs
    python3
    go
    rustup
    cargo
    openssl
    openssh
    git-lfs
    atuin

    # ── Productivity ───────────────────────────────────────────────
    obsidian
    libreoffice
    notion
    teams-for-linux

    # ── Media Production ─────────────────────────────────────────
    ffmpeg
    vlc
    spotify
    audacity
    inkscape
    gimp
    handbrake
    obs-studio

    # ── Gaming ────────────────────────────────────────────────
    steam
    steam-run
    discord
    mangohud
    lutris
    prismlauncher
    legendary-gl
    gamemode

    # ── Graphics & Video ──────────────────────────────────────
    chromium
    firefox
    mpv

    # ── Utilities ────────────────────────────────────────
    appimage-run
    unrar
    pkg-config
    gcc
    gnumake
    bison
    flex
    perl
    ruby
    lua
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # SECURITY
  # ═══════════════════════════════════════════════════════════════════════════════
  security.sudo.wheelNeedsPassword = false;

  # ═══════════════════════════════════════════════════════════════════════════════
  # KERNEL TUNING
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # FILE SYSTEMS
  # ═══════════════════════════════════════════════════════════════════════════════
  fileSystems."/home/tank/Games" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # BOOT
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}