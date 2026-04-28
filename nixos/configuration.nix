{ config, lib, pkgs, self, unstable, ... }:
{

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # IMPORTS
  # ═══════════════════════════════════════════════════════════════════════════════
  imports = [ ./hardware-configuration.nix ];

  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "bluetooth" "uinput" "input" "video" ];
    hashedPassword = "$6$RbFEFElMVrmuZlAS$f.Vd3dw5m72GdBN1Uc8mYGWooqwTDH5dt.cN3riTCLxMvcyuAjONGXUEFfaep11fW6tMQMWdjh46hTyN3NH3M1";
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # BOOTLOADER (rEFInd for Dual Boot)
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false; # Disable the default text loader
    refind.enable = true;
    refind.maxGenerations = 3;
    grub.enable = false;
  };
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "usbcore.autosuspend=-1" "nvidia-drm.modeset=1" ];
  hardware.nvidia.nvidiaPersistenced = true;

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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
  services.haveged.enable = true;

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
    forceFullCompositionPipeline = true;
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings.General.Enable = "Source,Media,Sink,Socket";

  # ═══════════════════════════════════════════════════════════════════════════════
  # AUDIO (PipeWire)
  # ═══════════════════════════════════════════════════════════════════════════════
  # JBL Quantum 810: use the 2.4GHz USB dongle (Harman device) as default.
  # The dongle exposes analog-stereo + mono-fallback which work cleanly.
  # The wired USB HiFi interface uses UCM which marks all routes availability:no
  # (except SPDIF) causing WirePlumber to skip the mic — avoid that path.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire."91-jbl-default" = {
      "context.properties" = {
        "default.audio.sink" = "alsa_output.usb-Harman_International_Inc_JBL_Quantum810_Wireless-00.analog-stereo";
        "default.audio.source" = "alsa_input.usb-Harman_International_Inc_JBL_Quantum810_Wireless-00.mono-fallback";
      };
    };
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # XDG PORTALS (required for screen sharing on Wayland)
  # ═══════════════════════════════════════════════════════════════════════════════
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # GAMING
  # ═══════════════════════════════════════════════════════════════════════════════
  programs.rsi-launcher = {
    enable = true;
    location = "$HOME/Games/rsi-launcher";
    umu.enable = true;
    setLimits = true;
    udevRules = true;
  };

  programs.steam = {
    enable = true; # you probably already have this
    extraCompatPackages = with unstable; [ proton-ge-bin ];
  };

  # Nice-to-have for any game (highly recommended for SE)
  programs.gamemode.enable = true; # Feral's gamemode
  # Force Steam to use system NVIDIA drivers  
  environment.sessionVariables = {
    NVIDIA_DRIVER_LIBRARIES = "1";
    NIX_GL_XARGS = "__GL_THREADED_OPTIMIZATION=1";
  };

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
    # ── Dev Tools ───────────────────────────────────────────────────────────
    openssh
    unstable.opencode

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
          --replace-fail '"$@"' '"$@" --enable-features=WebRTCPipeWireCapturer'
      '';
    }))
    mumble
    pkgs.moonlight-qt


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
  # KERNEL TUNING
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # FILE SYSTEMS
  # ═══════════════════════════════════════════════════════════════════════════════
  fileSystems."/home/tank/Games" = {
    device = "/dev/disk/by-uuid/bf5ad455-c95d-410c-af93-e67082f722db";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # SUNSHINE (Game Streaming Server)
  # ═══════════════════════════════════════════════════════════════════════════════
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    };
    settings = {
      sunshine_name = "tank";
      encoder = "nvenc";
      capture = "nvfbc";
    };
    applications.apps = [
      { name = "Desktop"; image-path = "desktop.png"; }
    ];
  };

  hardware.uinput.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # ZRAM SWAP
  # ═══════════════════════════════════════════════════════════════════════════════
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
    priority = 100;
  };

  system.stateVersion = "25.11";
}
