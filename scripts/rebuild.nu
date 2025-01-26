#!/usr/bin/env nu

def rebuild_nixos [changed: bool] {
  let flatpaks = ["app.zen_browser.zen"]

  if $changed {
    echo $"Rebuilding $(gum style --italic --foreground 99 'NixOS') machine..."
    nixos-rebuild switch --flake . --impure
    echo $"$(gum style --italic --foreground 99 'NixOS') rebuilt successfully."
  }

  for flatpak in $flatpaks {
    flatpak install flathub $flatpak
  }
}

def rebuild_darwin [changed: bool] {
  if not $changed  {
    return
  }

  echo $"rebuilding $(gum style --italic --foreground 99 'MacOS') machine..."
  darwin-rebuild switch --flake .
  echo $"$(gum style --italic --foreground 99 'nix-darwin') rebuilt successfully."
}

def rebuild_hm [] {
  echo $"rebuilding $(gum style --italic --foreground 99 'home-manager')..."
  home-manager switch --flake . --impure
  echo $"$(gum style --italic --foreground 99 'home-manager') rebuilt successfully."
}

def should_rebuild [...markers: string]  {
  let len = ($markers | length)

  let pattern = if $len == 1 {
    $markers | head
  } else {
    $markers | reduce {| it, acc | $it + "|" + $acc }
  }

  ((git status | rg $pattern | wc -l | into int) > 0)
}

def main [] {
  try {
    cd "~/Repos/home-setup"
  } catch {
    gum log --level='error' "Could not find ~/Repos/home-setup"
  }

  let nixos_changed: bool = should_rebuild "nixos"
  let darwin_changed: bool = should_rebuild "darwin"
  let hm_changed: bool = should_rebuild "scripts" "homemanager"

  echo $nixos_changed
  match (uname).kernel-name {
    "Linux" => {rebuild_nixos $nixos_changed},
    "Darwin" => {rebuild_darwin $darwin_changed},
    _ => {gum log --level='error' "Unknown OS"}
  }

  if $hm_changed {
    rebuild_hm
  }

  if $nixos_changed  {
    # NOTE: Only NixOS hosts can require a reboot after rebuilding
    gum spin --spinner dot --title "Rebooting now..." -- sleep 5
    sudo reboot now
  }
}
