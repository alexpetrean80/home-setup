b=$(git branch | fzf | tr -d '* ')
git checkout "$b"
