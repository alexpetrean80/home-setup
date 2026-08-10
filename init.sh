#!/usr/bin/env bash

case "$(uname)" in
Darwin)
	# run the multi-user nix installation
	sh <(curl -L https://nixos.org/nix/install)

	# init nix-darwin without having darwin-rebuild inside $PATH
	nix run nix-darwin -- switch --flake .
	;;
Linux)
	if [[ ! -e /etc/NIXOS ]]; then
		echo "this config only targets macOS and NixOS"
		exit 1
	fi

	# nix ships with NixOS, so no installer here. Flakes may not be
	# enabled yet on a fresh install, and the hostname is still the
	# installer default (nixos) rather than theseus, so pass both the
	# feature flags and the flake output explicitly.
	sudo nixos-rebuild switch \
		--option extra-experimental-features 'nix-command flakes' \
		--flake .#theseus
	;;
*)
	echo "this config only targets macOS and NixOS"
	exit 1
	;;
esac

# I don't want to have to refetch this repo after
# running the init script, so I'll usually
# nix-shell -p git gh to fetch this, so I need
# to remove the github-cli config as it is managed
# by home-manager
rm -rf "$HOME/.config/gh"
