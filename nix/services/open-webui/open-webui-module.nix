{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.open-webui;
in
{
  options.services.open-webui = {
    enable = mkEnableOption "Open WebUI service";

    imageTag = mkOption {
      type = types.str;
      # Check https://github.com/open-webui/open-webui/releases for the latest stable.
      # Using "main" will give you the latest development version.
      default = "main"; # Or a specific stable tag like "v0.1.123"
      description = "Docker image tag for ghcr.io/open-webui/open-webui.";
    };

    hostPort = mkOption {
      type = types.port;
      default = 3000; # User-facing port on the NixOS host
      description = "Port on the NixOS host to expose Open WebUI.";
    };

    containerPort = mkOption {
      type = types.port;
      default = 8080; # Open WebUI's Docker image exposes port 8080 by default
      description = "Port inside the container Open WebUI listens on.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/open-webui";
      description = "Directory on the host to store Open WebUI persistent data (/app/backend/data in container).";
    };

    extraEnvironmentVars = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        OLLAMA_BASE_URL = "http://host.docker.internal:11434";
        # OPENAI_API_KEY = "sk-yourkey";
        # OPENAI_API_BASE_URL = "https://api.openai.com/v1";
        # WEBUI_SECRET_KEY = "your_secret_key_here_for_persistent_sessions";
      };
      description = "Extra environment variables to pass to the Open WebUI container.";
    };

    pullPolicy = mkOption {
      type = types.enum [ "always" "missing" "never" ];
      default = if cfg.imageTag == "main" then "always" else "missing";
      defaultText = literalExpression ''if config.services.open-webui.imageTag == "main" then "always" else "missing"'';
      description = ''
        Docker image pull policy.
        'always': Always pull the image before starting. Good for rolling tags like 'main'.
        'missing': Pull the image only if it's not present locally. Good for versioned tags.
        'never': Never pull the image. Assumes it's already available locally.
      '';
    };

    extraDockerOptions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional options to pass to the 'docker run' equivalent, e.g., for networking.";
      example = [ "--add-host=host.docker.internal:host-gateway" ];
    };
  };

  config = mkIf cfg.enable {
    # Docker should be enabled in the system configuration.
    # virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers.open-webui = {
      image = "ghcr.io/open-webui/open-webui:${cfg.imageTag}";
      ports = [ "${toString cfg.hostPort}:${toString cfg.containerPort}" ];
      volumes = [
        "${cfg.dataDir}:/app/backend/data"
      ];
      environment = cfg.extraEnvironmentVars;
      autoStart = true;

      extraOptions =
        (if cfg.pullPolicy == "always" then [ "--pull=always" ]
         else if cfg.pullPolicy == "missing" then [ "--pull=missing" ]
         else []) ++ cfg.extraDockerOptions;
    };

    # Ensure the data directory exists and has appropriate permissions for the container
    # The container typically runs as non-root, check Open WebUI docs for UID/GID if issues arise.
    # For now, we assume Docker handles volume permissions or the default user is fine.
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
    ];
  };
}
