#!/usr/bin/env bash

home-manager switch --flake . --impure

sudo nixos-rebuild switch --flake . --impure

for flatpak in "io.github.zen_browser.zen"; do
  flatpak install flathub "$flatpak"
done

sudo reboot now
