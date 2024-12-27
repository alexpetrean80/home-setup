# make sure we don't fail the rebuild
# due to files not added to git
git add .

# Always be in the repo.
cd "$HOME/Repos/home-setup" || exit 1

# NOTE: Naive way of making the script only do the bare minimum.
# By convention the files are named in such a way such that
# I can see if a part of the flake has changed and
# only rebuild the required parts.
# This method rebuilds for refactors/reformats, but it's
# better than nothing.
nixos_changed=$(git status | rg "nixos" | wc -l)
nix_darwin_changed=$(git status | rg "darwin" | wc -l)
hm_chaned=$(git status | rg "homemanager|scripts" | wc -l) # also check if scripts changed as they are installed via home-manager

if [[ $nixos_changed -eq 0 && $hm_chaned -eq 0 && $nix_darwin_changed -eq 0 ]]; then
  echo "no op. exiting..."
  exit 0
fi

case "$(uname)" in
"Linux")
  echo "rebuilding Linux machine..."
  if [[ nixos_changed -ne 0 ]]; then
    sudo nixos-rebuild switch --flake . --impure
  fi

  #shellcheck disable=SC2043
  for flatpak in "io.github.zen_browser.zen"; do
    flatpak install flathub "$flatpak"
  done
  ;;
"Darwin")
  echo "rebuilding Mac..."
  if [[ nix_darwin_changed -ne 0 ]]; then
    darwin-rebuild switch --flake .
  fi
  ;;
*)
  echo "unsupported system"
  ;;
esac

if [[ hm_chaned -ne 0 ]]; then
  echo "rebuilding home-manager"...
  home-manager switch --flake . --impure
fi

echo "commit changes."
# commit changes such that subsequent rebuilds are no-ops.
read
lazygit

if [[ $nixos_changed -ne 0 ]]; then
  # NOTE: Only NixOS hosts can require a reboot after rebuilding
  sudo reboot now
fi
