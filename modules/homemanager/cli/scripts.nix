{ pkgs, lib, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "fzb" (lib.readFile ../../../scripts/fzb.sh))
    (pkgs.writeShellScriptBin "rebnix" (lib.readFile ../../../scripts/rebuild.sh))
  ];
}
