# Local overlay for nix-citizen packages, compatible with nixpkgs 25.11
# Builds rsi-launcher (umu variant) and lug-helper from local sources
# Uses umu-launcher + Proton (no wine-astral needed)
final: prev: {
  rsi-launcher = final.callPackage ./pkgs/rsi-launcher {
    wine = prev.wine;
    winetricks = prev.winetricks;
    wineprefix-preparer = prev.writeShellScriptBin "wineprefix-preparer" "true";
    umu-launcher = prev.umu-launcher;
    proton-ge-bin = prev.proton-ge-bin;
    rsi-installer = final.callPackage ./pkgs/rsi-launcher/installer.nix {};
    useUmu = true;
  };

  lug-helper = final.callPackage ./pkgs/lug-helper {
    winetricks = prev.winetricks;
  };
}
