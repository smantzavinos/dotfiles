
{ pkgs, flags, ... }:

let
  # Define the full path for secrets file
  secretsFile = ./secrets/secrets.yaml;
  ageKeyFile = "/home/spiros/.config/sops/age/keys.txt";
in
{

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver =  {
    xkb.options = "ctrl:nocaps";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    openssl
  ];

  # secrets management
  sops.defaultSopsFile = secretsFile;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = ageKeyFile;

  # networking.firewall.enable = false;

  # hdhomerun ports
  # networking.firewall.allowedTCPPorts = [ 65001 ];
  # networking.firewall.allowedUDPPorts = [ 65001 ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;
  users.users.spiros.extraGroups = [ "docker" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;  # Ensure PostgreSQL v14 as suggested by Plandex
    ensureDatabases = [ "plandex" ];
    settings = {
      ssl = true;
    };
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      # host  sameuser    all     127.0.0.1/32 scram-sha-256
      # host  sameuser    all     ::1/128 scram-sha-256
      # Allow IPv4 localhost connections
      host    all             all             127.0.0.1/32            trust
      # Allow IPv6 localhost connections (this is the important part)
      host    all             all             ::1/128                 trust
    '';

    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root       postgres
      superuser_map      postgres   postgres

      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';
  };

  # programs.steam = {
  #   enable = flags.enableSteam; # NOTE: Accessing flags on Lenovo X1 Extreme was failing here.
                                  #       Seems to be working fine on other systems.
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  # };
}
