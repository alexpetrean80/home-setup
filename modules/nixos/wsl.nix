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

  # Links open in the Windows browser, two routes:
  # - xdg-open (nvim gx, lazygit, gh-dash, node's `open`): xdg-utils >= 1.2
  #   detects WSL on its own (microsoft in /proc/version + explorer.exe on
  #   PATH, i.e. Windows PATH interop left on) and hands the URL to
  #   rundll32.exe. Explicit here — it must not ride on docker-desktop's
  #   incidental xdg-utils.
  # - BROWSER (gh, python's webbrowser: gcloud/az/aws sso): wslview from wslu
  #   does the same via cmd.exe. Also the xdg-open fallback if WSL detection
  #   ever fails, and the mimeapps handler on the home-manager side.
  environment.systemPackages = with pkgs; [
    wslu
    xdg-utils
  ];
  environment.variables.BROWSER = "wslview";
}
