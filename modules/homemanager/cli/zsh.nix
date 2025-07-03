{ ... }: {
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    defaultKeymap = "viins";

    initContent = ''
      source $HOME/.zprofile
      export GOPATH="$HOME/go/"
      export PATH="$GOPATH:$HOME/.local/share/npm/bin:$HOME/.local/share/fnm:$HOME/.cargo/bin:$GOPATH/bin:$HOME/.local/bin:$PATH"
      export EDITOR="nvim"
      export VISUAL="nvim"
    '';

    shellAliases = {
      lzg = "lazygit";
      ls = "eza -lgh";
      dc = "docker compose";
      dcu = "docker compose up";
      dce = "docker compose exec";
      dcb = "docker compose build";
      dcd = "docker compose down";
      dcr = "docker compose run";
    };

    antidote = {
      enable = true;
      plugins = [
        "ohmyzsh/ohmyzsh path:plugins/fzf"
        "ohmyzsh/ohmyzsh path:plugins/zsh-interactive-cd"
        "ohmyzsh/ohmyzsh path:plugins/command-not-found"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
      ];
    };
  };
}
