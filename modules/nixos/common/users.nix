{pkgs, ...}: {
  users.users = {
    alexp = {
      isNormalUser = true;
      description = "Alex Petrean";
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;
    };
    iul = {
      isNormalUser = true;
      description = "Iulia";
      extraGroups = ["networkmanager" "wheel"];
      shell = pkgs.zsh;
    };
  };
}
