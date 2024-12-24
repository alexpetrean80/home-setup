{ pkgs, lib, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "fzb" (lib.readFile ../../../scripts/fzb.sh))
  ];
}
