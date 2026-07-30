# Steam has to be a system module, not a home-manager package: it needs the
# 32-bit graphics stack, its own FHS wrapper and firewall holes.
#
# Reality check on this box: UHD 630 (Gen9) is fine for indie/2D titles and
# older 3D at 720-1080p low. Proton works, performance is what it is.
{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play / Link
    localNetworkGameTransfers.openFirewall = true;
    # GE-Proton alongside valve's Proton — picked per-game in properties.
    extraCompatPackages = [pkgs.proton-ge-bin];
    # gamescope as a nested compositor: fixes resolution/scaling for games that
    # fight tiling WMs. Launch option: `gamescope -W 1920 -H 1080 -- %command%`
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # Steam ships 32-bit binaries; without enable32Bit games get llvmpipe
  # (software rendering) instead of i965/iris.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Controllers work out of the box via the in-kernel xpad driver. If you want
  # the better bluetooth/rumble support, add `hardware.xpadneo.enable = true` —
  # it is an out-of-tree kernel module, so it can break a kernel bump.

  environment.systemPackages = with pkgs; [
    mangohud # frame/temp overlay: `mangohud %command%`
    protontricks
  ];
}
