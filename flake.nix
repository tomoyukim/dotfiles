{
  description = "Home Manager configuration of tomoyukim";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    codex-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixgl.url = "github:nix-community/nixGL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay/f1a553f7f35c88116a89832e8f6da35473d732f2"; # 2026/09/12
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dracula-tmux = {
      url = "github:dracula/tmux/5eb04b9db918bdfbf6928fc3b59942efb7de6e54";
      flake = false;
    };
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
    sops-nix.url = "github:Mic92/sops-nix";
    private = {
      url = "git+ssh://git@github.com/tomoyukim/dotfiles-private.git";
    };
  };

  outputs = { ... }@inputs:
    let
      username = "tomoyukim";
      hosts = {
        audrey = {
          system = "aarch64-linux";
          module = ./hosts/audrey.nix;
        };
        silvie = {
          system = "x86_64-linux";
          module = ./hosts/default.nix;
        };
        macbook = {
          system = "aarch64-darwin";
          module = ./hosts/default.nix;
        };
      };
      nixgl = inputs.nixgl;
      sops-nix = inputs.sops-nix;
      mkHomeConfiguration = { host }:
        let
          hostConfig = if builtins.hasAttr host hosts
                       then hosts.${host}
                       else throw "Unknown Home Manager host '${host}'. Register it in flake.nix.";
          pkgs = import inputs.nixpkgs {
            inherit (hostConfig) system;
            config.allowUnfree = true;
            overlays = [
              inputs.emacs-overlay.overlay
              inputs.nix-claude-code.overlays.default
              (final: prev: {
                jquants-cli = prev.callPackage ./pkgs/jquants-cli.nix {};
              })
            ];
          };
          codexPkgs = import inputs.codex-nixpkgs {
            inherit (hostConfig) system;
            config.allowUnfree = true;
          };
        in inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs.extend (final: prev: {
            tmuxPlugins = prev.tmuxPlugins // {
              dracula = prev.tmuxPlugins.dracula.overrideAttrs (oldAttrs: {
                version = "3.0.0";
                src = inputs.dracula-tmux;
              });
            };
          });

          extraSpecialArgs = {
            inherit username;
            inherit nixgl;
            inherit (inputs) private;
            codexPackage = codexPkgs.codex;
          };

          modules = [
            ./home.nix
            sops-nix.homeManagerModules.sops
            hostConfig.module
          ];
        };
    in {
      homeConfigurations = builtins.listToAttrs (map
        (host: {
          name = "${username}@${host}";
          value = mkHomeConfiguration { inherit host; };
        })
        (builtins.attrNames hosts));
    };
}
