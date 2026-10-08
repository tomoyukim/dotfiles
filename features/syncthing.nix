{ ... }:

{
  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        "org-notes" = {
          path = "~/.org";
          devices = [ "nas" ];
        };
      };
    };
  };
}
