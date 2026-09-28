# WSL half of the base: NixOS running as a WSL2 distro on a Windows host.
# Pairs with core.nix only — no physical.nix (Windows owns the hardware) and no
# sway.nix/steam.nix (the terminal and any GUI live on the Windows side).
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nixos-wsl.nixosModules.default];

  wsl = {
    enable = true;
    # Who `wsl -d NixOS` logs in as. NixOS-WSL creates this user itself (uid
    # 1000, wheel, passwordless sudo); core.nix layers shell/docker on top.
    # Changing it on a live install must go through `nixos-rebuild boot` plus
    # a `wsl -t` restart, never `switch` — see init.sh.
    defaultUser = "alexp";
    # /etc/wsl.conf is generated from wsl.wslConf; its hostname follows
    # networking.hostName, and a change only lands after `wsl --shutdown`.
  };

  # Docker Desktop runs on the Windows side and reaches into this distro via
  # its WSL integration (Docker Desktop → Settings → Resources → WSL
  # integration → enable for this distro). This module gives that integration
  # the /bin shims it expects, puts alexp in the docker group and installs
  # xdg-utils so compose can open docker-desktop:// links. No native daemon —
  # that is physical.nix's business.
  wsl.docker-desktop.enable = true;

  # Foreign dynamic binaries (VS Code's Remote-WSL server, hand-downloaded
  # CLIs) expect /lib64/ld-linux-x86-64.so.2. nix-ld provides it — the fix
  # NixOS-WSL's own docs recommend.
  programs.nix-ld.enable = true;

  # `wslview` hands URLs/files to the Windows default app. Pointing BROWSER at
  # it is what makes `gh auth login` and friends open the Windows browser.
  environment.systemPackages = [pkgs.wslu];
  environment.variables.BROWSER = "wslview";
}
