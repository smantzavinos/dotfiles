{ config, pkgs, ... }:

{
  systemd.services.litellm = {
    description = "LiteLLM Docker Container Service";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          -v /etc/litellm/config.yaml:/app/config.yaml \
          --env-file ${config.sops.secrets.litellm.path} \
          -e MODEL='gpt-4o' \
          -p 4000:4000 \
          ghcr.io/berriai/litellm:main-latest --config /app/config.yaml --detailed_debug
      '';
      Restart = "always";
      RestartSec = "10";
    };
    wantedBy = [ "multi-user.target" ];
  };
}

