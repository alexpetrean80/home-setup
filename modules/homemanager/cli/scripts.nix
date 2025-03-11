{ pkgs, lib, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "fzb" (lib.readFile ../../../scripts/fzb.sh))
    (pkgs.writeShellScriptBin "rebnix" (lib.readFile ../../../scripts/rebuild.sh))
    (pkgs.writeShellScriptBin "is_vim" (lib.readFile ../../../scripts/is_vim.sh))
  ];
}
