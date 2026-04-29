{ config, lib, pkgs, self ,unstable, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # BOOTLOADER
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 3;
    grub.enable = false;
  };


  # ═══════════════════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════════════════
  networking.hostName = "tankles";
  networking.networkmanager.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  security.rtkit.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # KDE Wallet (for keyring/password storage)
  security.pam.services.sddm.enableKwallet = true;

  environment.systemPackages = with pkgs; [
  ];

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
      sunshine_name = "tankles";
      encoder = "nvenc";
      capture = "kms";
      adapter_name = "/dev/dri/card1";
    };
    applications.apps = [
      { name = "Desktop"; image-path = "desktop.png"; }
    ];
  };

  hardware.uinput.enable = true;


  system.stateVersion = "25.11";

}
