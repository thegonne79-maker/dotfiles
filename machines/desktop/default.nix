{ config, lib, pkgs, self, unstable, ... }:
{

  # ═══════════════════════════════════════════════════════════════════════════════════════
  # IMPORTS
  # ═══════════════════════════════════════════════════════════════════════════════
  imports = [ ./hardware-configuration.nix ];


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


  # ═══════════════════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════════════════
  networking.hostName = "tank";
  networking.networkmanager.enable = true;



  # ═══════════════════════════════════════════════════════════════════════════════
  # GRAPHICS (NVIDIA)
  # ═══════════════════════════════���═══════════════════════════════════════════════
  services.xserver.videoDrivers = [ "nvidia" ];
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
  services.pipewire.extraConfig.pipewire."91-jbl-default" = {
    "context.properties" = {
      "default.audio.sink" = "alsa_output.usb-Harman_International_Inc_JBL_Quantum810_Wireless-00.analog-stereo";
      "default.audio.source" = "alsa_input.usb-Harman_International_Inc_JBL_Quantum810_Wireless-00.mono-fallback";
    };
  };
  # Force Steam to use system NVIDIA drivers  
  environment.sessionVariables = {
    NVIDIA_DRIVER_LIBRARIES = "1";
    NIX_GL_XARGS = "__GL_THREADED_OPTIMIZATION=1";
  };

  fileSystems."/home/tank/real_drive_c" =
  {
     device= "/dev/nvme0n1p3";
     fsType = "ntfs3";
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


  system.stateVersion = "25.11";
}
