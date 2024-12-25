#!/usr/bin/env bash

uname=$(uname)

host=$HOST

if [[ uname == "Linux" ]]; then
  # checking the existence of a battery to determine
  # if the computer is a laptop or desktop
  # NOTE: We are overriding the hostname only for Linux
  # hosts as only the NixOS-based flakes are defined
  # with the NixOS set hostnames.
  if [[ -e "/sys/class/power_supply/BAT0" ]]; then
    host=daslaptop
  else
    host=dascomp
  fi

  # just switch to the flake's definition
  # NOTE: We need the hostname because
  # the hostname used in the flake is changed
  # through the flake itself.
  sudo nixos-rebuild switch --flake ".#$host" --impure
elif [[ uname == "Darwin" ]]; then
  # run the multi-user nix installation
  sh <(curl -L https://nixos.org/nix/install)

  # init nix-darwin without having darwin-rebuild inside $PATH
  nix run nix-darwin -- switch --flake .
else
  echo "unsupported system"
fi

# I don't want to have to refetch this repo after
# running the init script, so I'll usually
# nix-shell -p git gh to fetch this, so I need
# to remove the github-cli config as it is managed
# by home-manager
rm -rf $HOME/.config/gh

nix run home-manager switch --flake ".#$(whoami)@$host"
