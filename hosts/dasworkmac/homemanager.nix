{ pkgs
, lib
, ...
}: {
  imports = [
    ../../modules/homemanager/gui
  ];

  programs = {
    git.includes = [
      {
        contents = {
          user = {
            email = "alex-tudor.petrean@snyk.io";
            signingkey = "E51D11C1C401B8F1FA26DA7301D2E393ABC8B299";
          };
          commit = {
            gpgSign = true;
          };
        };
      }
    ];
  };

  home.packages = with pkgs; [
    aws-vault
    terraform
    tilt
    confluent-cli
    jdk17
    darwin.CF
    darwin.Libc
    darwin.Security
    jira-cli-go
  ];


  home.file.".config/ghostty" = {
    source = lib.mkForce ./config/ghostty;
  };
  home = {
    username = "alexp";
    homeDirectory = lib.mkForce "/Users/alexp";
    stateVersion = "24.05";
  };

}

