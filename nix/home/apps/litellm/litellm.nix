{ config, pkgs, ... }:

{
  systemd.services.litellm = {
    description = "LiteLLM Docker Container Service";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          -v /nix/home/apps/litellm/config.yaml:/app/config.yaml \
          -e AZURE_API_KEY_EU=$(cat ${config.sops.secrets.aiApiKeys.path} | yq eval '.AZURE_API_KEY_EU' -) \
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

