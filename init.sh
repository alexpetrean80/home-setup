#!/usr/bin/env bash

if [[ "$(uname)" != "Darwin" ]]; then
	echo "this config only targets macOS"
	exit 1
fi

# run the multi-user nix installation
sh <(curl -L https://nixos.org/nix/install)

# init nix-darwin without having darwin-rebuild inside $PATH
nix run nix-darwin -- switch --flake .

# I don't want to have to refetch this repo after
# running the init script, so I'll usually
# nix-shell -p git gh to fetch this, so I need
# to remove the github-cli config as it is managed
# by home-manager
rm -rf "$HOME/.config/gh"
