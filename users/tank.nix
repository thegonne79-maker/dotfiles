{ config, unstable, self, pkgs, lib, ... }:
{

  programs.ssh.enableAskPassword = false;
  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-tty;

    enable = true;
    enableSSHSupport = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tank = {
    isNormalUser = true;
    name = "tank";
    description = "brat tamer";
    createHome = true;
    home = "/home/tank";
    extraGroups = [ "wheel" "audio" "bluetooth" "uinput" "input" "video" ];
    hashedPassword = "$6$RbFEFElMVrmuZlAS$f.Vd3dw5m72GdBN1Uc8mYGWooqwTDH5dt.cN3riTCLxMvcyuAjONGXUEFfaep11fW6tMQMWdjh46hTyN3NH3M1";
    openssh.authorizedKeys.keys = [
      "${lib.readFile ../public-keys/tankles-user-desktop.pub}"
    ];
  };


}
