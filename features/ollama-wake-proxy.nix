{ lib, pkgs, ... }:

let
  wolProxy = pkgs.writeScriptBin "wol-proxy" (
    builtins.readFile ../scripts/wol-proxy.py
  );
  ollamaWakeProxy = pkgs.writeScriptBin "ollama-wake-proxy" (
    builtins.readFile ../scripts/ollama-wake-proxy.py
  );
in
{
  systemd.user.services = {
    wol-proxy = {
      Unit = {
        Description = "Wake-on-LAN HTTP proxy";
      };
      Service = {
        ExecStart = "${pkgs.python3}/bin/python ${wolProxy}/bin/wol-proxy";
        Environment = [
          "PATH=${lib.makeBinPath [ pkgs.wakeonlan ]}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
      Install.WantedBy = [ "default.target" ];
    };

    ollama-wake-proxy = {
      Unit = {
        Description = "Ollama proxy with Wake-on-LAN wake-up";
        Requires = [ "wol-proxy.service" ];
        After = [ "wol-proxy.service" ];
      };
      Service = {
        ExecStart = "${pkgs.python3}/bin/python ${ollamaWakeProxy}/bin/ollama-wake-proxy";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
