
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

   # Ensure the SSL directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/postgresql/ssl 0700 postgres postgres -"
  ];

  # Activation script to generate the self-signed SSL certificate and key
  system.activationScripts.postgresSSL = ''
    ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -nodes -text \
      -out /var/lib/postgresql/ssl/server.crt \
      -keyout /var/lib/postgresql/ssl/server.key \
      -subj "/CN=localhost"

    chown postgres:postgres /var/lib/postgresql/ssl/server.key /var/lib/postgresql/ssl/server.crt
    chmod 600 /var/lib/postgresql/ssl/server.key
    chmod 644 /var/lib/postgresql/ssl/server.crt
  '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureDatabases = [ "plandex" ];
    settings = {
      ssl = true;
      ssl_cert_file = "/var/lib/postgresql/ssl/server.crt";
      ssl_key_file = "/var/lib/postgresql/ssl/server.key";
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
