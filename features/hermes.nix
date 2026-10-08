{ config, ... }:

{
  services.hermes-agent = {
    enable = true;
    gateway.enable = true;

    configFile = ../hermes/config.yaml;
    hermesHomeFiles = {
      "SOUL.md" = ../hermes/SOUL.md;
    };
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 8642;
    };
    environmentFiles = [
      config.sops.secrets."hermes-env".path
    ];
  };
}
