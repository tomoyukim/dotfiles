{ private, ... }:
{
  imports = [
    ../features/syncthing.nix
    "${private}/syncthing.nix"
    private.homeManagerModules.audrey
  ];
}
