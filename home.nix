{ config, lib, pkgs, username, nixgl, codexPackage, ... }:

rec {
  targets.genericLinux.nixGL = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  home = {
    inherit username;
    homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin
                    then "/Users/${username}"
                    else "/home/${username}";

    stateVersion = "25.11";

    packages = with pkgs; [
      hyfetch
      ripgrep
      silver-searcher-ng
      fd
      age
      pkgs.sops
      ghq
      diff-so-fancy
      global
      roswell
      zmx
      # c/c++
      gcc
      clang-tools
      # for emacs
      cmigemo
      xapian
      pass
      syncthing
      # for logseq sync (https://scrapbox.io/scrapseibe/Logseq%E3%82%92GitHub%E7%B5%8C%E7%94%B1%E3%81%A7%E5%90%8C%E6%9C%9F)
      git-credential-manager
      # for nix
      nix-prefetch-git
      nix-prefetch-github
      # network
      dnsutils # for dig command
      whois
      # ai
      rtk
      uv
      codexPackage
      claude-code
      jquants-cli
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/tomoyukim/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      # EDITOR = "emacs";
    };

    sessionPath = [
      "$HOME/bin"
      "$HOME/.local/bin"
    ];
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;

#    alacritty = import ./programs/alacritty.nix { inherit nixgl pkgs config;  };
    bash = import ./programs/bash.nix;
    fish = import ./programs/fish.nix { inherit pkgs; };
    starship = import ./programs/starship.nix { inherit lib; };
    tmux = import ./programs/tmux.nix { inherit pkgs; };
    zoxide = import ./programs/zoxide.nix;
    git = import ./programs/git.nix { inherit home; };

    bat.enable = true;
    gpg.enable = true;
    gh.enable = true;
    jq.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    emacs = {
      enable = true;
      package = pkgs.emacs;
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package =
      if pkgs.stdenv.hostPlatform.isDarwin
      then pkgs.pinentry_mac
      else pkgs.pinentry-tty;
  };

}
