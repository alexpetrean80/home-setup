{...}: {
  imports = [
    <nixos-wsl/modules>

    ../../../modules/nixos/server
  ];

  wsl = {
    enable = true;
    defaultUser = "alexp";
  };

  system.stateVersion = "23.11";
}
