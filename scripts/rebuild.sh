# make sure we don't fail the rebuild
# due to files not added to git
git add .

# Always be in the repo.
cd "$HOME/Repos/home-setup" || exit 1

while getopts 'n' opt; do
	case "$opt" in
	n)
		# flag to always update. useful when the config changes
		# on another machine and this one must be brought up to date.
		changed=1
		;;
	?)
		# NOTE: Naive way of making the script only do the bare minimum.
		# home-manager is integrated into nix-darwin, so any darwin,
		# homemanager or scripts change is applied by a single rebuild.
		# This method rebuilds for refactors/reformats, but it's
		# better than nothing.
		changed=$(git status | rg "darwin|homemanager|scripts" | wc -l)

		if [[ $changed -eq 0 ]]; then
			gum log --level='info' 'no op. exiting...'
			exit 0
		fi
		;;
	esac
done

echo "rebuilding $(gum style --italic --foreground 99 'macOS') machine..."
sudo darwin-rebuild switch --flake .
echo "$(gum style --italic --foreground 99 'nix-darwin') rebuilt successfully."

# commit changes such that subsequent rebuilds are no-ops.
gum confirm "Wanna commit changes?" && lazygit
