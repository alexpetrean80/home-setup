mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
$env.config.edit_mode = "vi"

# make fnm work 
use std "path add"
fnm env --json | from json | load-env
path add ($env.FNM_MULTISHELL_PATH + "/bin")

if ('~/.zprofile' | path exists) {
  open ~/.zprofile | lines | str replace "export " "" | str join "\n" | from toml | load-env
}
