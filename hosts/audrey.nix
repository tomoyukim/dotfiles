{ private, ... }:
{
  imports = [
    ../features/syncthing.nix
    ../features/hermes.nix
    ../features/ollama-wake-proxy.nix
    "${private}/ollama-wake-proxy.nix"
  ];
}
