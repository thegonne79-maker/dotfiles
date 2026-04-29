{ pkgs, lib, config, self, unstable, ... }:
{

  imports = [ ./communications.nix ];

  programs.ssh.enableAskPassword = false;
  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-tty;
    enable = true;
    enableSSHSupport = true;
  };
  # ═══════════════════════════════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config.allowUnfree = true;
  networking.extraHosts = ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';
  services.tailscale.enable = true;
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
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.defaultSession = "plasmax11";
  services.openssh.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;



  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # GAMING
  # ═══════════════════════════════════════════════════════════════════════════════

  programs.steam = {
    enable = true; # you probably already have this
    extraCompatPackages = with unstable; [ proton-ge-bin ];
  };

  # Nice-to-have for any game (highly recommended for SE)
  programs.gamemode.enable = true; # Feral's gamemode
  programs.steam.remotePlay.openFirewall = true;

  # ═══════════════════════════════════════════════════════════════════════════
  # SYSTEM PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [

    # ── Base Utilities ─────────────────────────────────────────────────────────────
    vim
    figlet
    lolcat
    tarts
    cmatrix
    jq
    wget
    git
    htop
    bat
    unzip
    gzip
    tmate
    swww
    btop
    bottom
    nvtopPackages.nvidia
    lite-xl
    # ── Dev Tools ───────────────────────────────────────────────────────────

    openssh
    unstable.opencode
    neovim

    # ── Productivity ───────────────────────────────────────────────
    obsidian
    libreoffice

    # ── Media Production ─────────────────────────────────────────

    vlc
    spotify
    gimp
    handbrake

    # ── Gaming ────────────────────────────────────────────────

    unstable.prismlauncher # FTBifi
    unstable.vintagestory
    steam
    steam-run
    (discord.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        substituteInPlace $out/opt/Discord/Discord \
          --replace-fail '"$@"' '"$@" --enable-features=WebRTCPipeWireCapturer --disable-gpu'
      '';
    }))
    mumble
    pkgs.moonlight-qt
    # Vulkan and DirectX support for Star Citizen
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    mesa
    libva
    libva-utils
    # 32-bit Vulkan for DXVK
    pkgsi686Linux.vulkan-loader
    pkgsi686Linux.mesa


    # ── Graphics & Video ──────────────────────────────────────

    chromium
    firefox
    unstable.vivaldi

    # ── Utilities ────────────────────────────────────────

    ripgrep
    magic-wormhole
    unrar
    pkg-config

  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # SECURITY
  # ═══════════════════════════════════════════════════════════════════════════════
  security.sudo.wheelNeedsPassword = false;
  # ═══════════════════════════════════════════════════════════════════════════════
  # ZRAM SWAP
  # ═══════════════════════════════════════════════════════════════════════════════
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };
  hardware.uinput.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

}
