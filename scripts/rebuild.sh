# Always be in the repo (before `git add`, or it stages the wrong tree).
cd "$HOME/Repos/home-setup" || exit 1

# make sure we don't fail the rebuild
# due to files not added to git
git add .

while getopts 'n' opt; do
	case "$opt" in
	n)
		# flag to always update. useful when the config changes
		# on another machine and this one must be brought up to date.
		changed=1
		;;
	?)
		# NOTE: Naive way of making the script only do the bare minimum.
		# home-manager is integrated into nix-darwin / NixOS, so any system,
		# homemanager, dotfiles or scripts change is applied by a single
		# rebuild. This method rebuilds for refactors/reformats, but it's
		# better than nothing.
		changed=$(git status | rg "darwin|nixos|homemanager|dotfiles|scripts" | wc -l)

		if [[ $changed -eq 0 ]]; then
			gum log --level='info' 'no op. exiting...'
			exit 0
		fi
		;;
	esac
done

# nix-darwin activation touches /Applications/Nix Apps/*.app, which macOS gates
# behind the App Management TCC grant. TCC can only prompt a caller that lives in
# the Aqua (GUI) session, and a tmux server daemonises itself out of Aqua — every
# shell under it reports `launchctl managername` = Background — so activation
# aborts with the misleading "permission denied ... over SSH" error. Bounce into a
# Ghostty window instead: Launch Services starts it in Aqua, so the one-time
# permission prompt has somewhere to land. Grant it to Ghostty when it appears.
if [[ "$(uname)" == "Darwin" && "$(launchctl managername)" != "Aqua" ]]; then
	self="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
	gum log --level='info' 'not a GUI session (tmux); reopening the rebuild in Ghostty...'
	exec open -na Ghostty --args -e /bin/bash -c \
		"'$self' $*; printf '\npress enter to close '; read -r _"
fi

# One repo, two kinds of host: nix-darwin on the mac, NixOS on theseus.
# nixos-rebuild picks the flake output matching the hostname on its own.
if [[ "$(uname)" == "Darwin" ]]; then
	echo "rebuilding $(gum style --italic --foreground 99 'macOS') machine..."
	sudo darwin-rebuild switch --flake .
	echo "$(gum style --italic --foreground 99 'nix-darwin') rebuilt successfully."
else
	echo "rebuilding $(gum style --italic --foreground 99 "$(hostname)") machine..."
	# --impure: hosts/theseus/nixos.nix reads /etc/nixos/hardware-configuration.nix
	# (the machine's own generated config) instead of a checked-in copy.
	sudo nixos-rebuild switch --flake . --impure
	echo "$(gum style --italic --foreground 99 'nixos') rebuilt successfully."
fi

# commit changes such that subsequent rebuilds are no-ops.
gum confirm "Wanna commit changes?" && lazygit
