{ config, pkgs, flags, ... }:

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
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };
  programs.ssh.startAgent = true;

  # SOPS-Nix secret for PIA credentials
  sops.secrets.pia = {
    sopsFile = ./secrets/pia-credentials.sops.yaml;
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # SOPS-Nix secret for LiteLLM credentials
  sops.secrets.litellm = {
    sopsFile = ./secrets/litellm_secrets.sops.yaml;
    owner = "root";
    group = "root";
    mode = "0600";
  };

  # fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    font-awesome
    emacs-all-the-icons-fonts
    material-icons
    weather-icons
  ];

  # Enable network manager if you want to manage the VPN via Network Manager as well
  networking.networkmanager.enable = true;

  services.openvpn.servers = {
    pia = {
      # config = null; # Explicitly set config to null since we're using configFile
      # configFile = ./vpn/us_east.ovpn;
      config = ''
        client
        dev tun
        proto udp
        remote us-newjersey.privacy.network 1197
        resolv-retry infinite
        nobind
        persist-key
        persist-tun
        cipher aes-256-cbc
        auth sha256
        tls-client
        remote-cert-tls server

        auth-user-pass ${config.sops.secrets.pia.path}
        compress
        verb 1
        reneg-sec 0

        <ca>
        -----BEGIN CERTIFICATE-----
        MIIHqzCCBZOgAwIBAgIJAJ0u+vODZJntMA0GCSqGSIb3DQEBDQUAMIHoMQswCQYD
        VQQGEwJVUzELMAkGA1UECBMCQ0ExEzARBgNVBAcTCkxvc0FuZ2VsZXMxIDAeBgNV
        BAoTF1ByaXZhdGUgSW50ZXJuZXQgQWNjZXNzMSAwHgYDVQQLExdQcml2YXRlIElu
        dGVybmV0IEFjY2VzczEgMB4GA1UEAxMXUHJpdmF0ZSBJbnRlcm5ldCBBY2Nlc3Mx
        IDAeBgNVBCkTF1ByaXZhdGUgSW50ZXJuZXQgQWNjZXNzMS8wLQYJKoZIhvcNAQkB
        FiBzZWN1cmVAcHJpdmF0ZWludGVybmV0YWNjZXNzLmNvbTAeFw0xNDA0MTcxNzQw
        MzNaFw0zNDA0MTIxNzQwMzNaMIHoMQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0Ex
        EzARBgNVBAcTCkxvc0FuZ2VsZXMxIDAeBgNVBAoTF1ByaXZhdGUgSW50ZXJuZXQg
        QWNjZXNzMSAwHgYDVQQLExdQcml2YXRlIEludGVybmV0IEFjY2VzczEgMB4GA1UE
        AxMXUHJpdmF0ZSBJbnRlcm5ldCBBY2Nlc3MxIDAeBgNVBCkTF1ByaXZhdGUgSW50
        ZXJuZXQgQWNjZXNzMS8wLQYJKoZIhvcNAQkBFiBzZWN1cmVAcHJpdmF0ZWludGVy
        bmV0YWNjZXNzLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALVk
        hjumaqBbL8aSgj6xbX1QPTfTd1qHsAZd2B97m8Vw31c/2yQgZNf5qZY0+jOIHULN
        De4R9TIvyBEbvnAg/OkPw8n/+ScgYOeH876VUXzjLDBnDb8DLr/+w9oVsuDeFJ9K
        V2UFM1OYX0SnkHnrYAN2QLF98ESK4NCSU01h5zkcgmQ+qKSfA9Ny0/UpsKPBFqsQ
        25NvjDWFhCpeqCHKUJ4Be27CDbSl7lAkBuHMPHJs8f8xPgAbHRXZOxVCpayZ2SND
        fCwsnGWpWFoMGvdMbygngCn6jA/W1VSFOlRlfLuuGe7QFfDwA0jaLCxuWt/BgZyl
        p7tAzYKR8lnWmtUCPm4+BtjyVDYtDCiGBD9Z4P13RFWvJHw5aapx/5W/CuvVyI7p
        Kwvc2IT+KPxCUhH1XI8ca5RN3C9NoPJJf6qpg4g0rJH3aaWkoMRrYvQ+5PXXYUzj
        tRHImghRGd/ydERYoAZXuGSbPkm9Y/p2X8unLcW+F0xpJD98+ZI+tzSsI99Zs5wi
        jSUGYr9/j18KHFTMQ8n+1jauc5bCCegN27dPeKXNSZ5riXFL2XX6BkY68y58UaNz
        meGMiUL9BOV1iV+PMb7B7PYs7oFLjAhh0EdyvfHkrh/ZV9BEhtFa7yXp8XR0J6vz
        1YV9R6DYJmLjOEbhU8N0gc3tZm4Qz39lIIG6w3FDAgMBAAGjggFUMIIBUDAdBgNV
        HQ4EFgQUrsRtyWJftjpdRM0+925Y6Cl08SUwggEfBgNVHSMEggEWMIIBEoAUrsRt
        yWJftjpdRM0+925Y6Cl08SWhge6kgeswgegxCzAJBgNVBAYTAlVTMQswCQYDVQQI
        EwJDQTETMBEGA1UEBxMKTG9zQW5nZWxlczEgMB4GA1UEChMXUHJpdmF0ZSBJbnRl
        cm5ldCBBY2Nlc3MxIDAeBgNVBAsTF1ByaXZhdGUgSW50ZXJuZXQgQWNjZXNzMSAw
        HgYDVQQDExdQcml2YXRlIEludGVybmV0IEFjY2VzczEgMB4GA1UEKRMXUHJpdmF0
        ZSBJbnRlcm5ldCBBY2Nlc3MxLzAtBgkqhkiG9w0BCQEWIHNlY3VyZUBwcml2YXRl
        aW50ZXJuZXRhY2Nlc3MuY29tggkAnS7684Nkme0wDAYDVR0TBAUwAwEB/zANBgkq
        hkiG9w0BAQ0FAAOCAgEAJsfhsPk3r8kLXLxY+v+vHzbr4ufNtqnL9/1Uuf8NrsCt
        pXAoyZ0YqfbkWx3NHTZ7OE9ZRhdMP/RqHQE1p4N4Sa1nZKhTKasV6KhHDqSCt/dv
        Em89xWm2MVA7nyzQxVlHa9AkcBaemcXEiyT19XdpiXOP4Vhs+J1R5m8zQOxZlV1G
        tF9vsXmJqWZpOVPmZ8f35BCsYPvv4yMewnrtAC8PFEK/bOPeYcKN50bol22QYaZu
        LfpkHfNiFTnfMh8sl/ablPyNY7DUNiP5DRcMdIwmfGQxR5WEQoHL3yPJ42LkB5zs
        6jIm26DGNXfwura/mi105+ENH1CaROtRYwkiHb08U6qLXXJz80mWJkT90nr8Asj3
        5xN2cUppg74nG3YVav/38P48T56hG1NHbYF5uOCske19F6wi9maUoto/3vEr0rnX
        JUp2KODmKdvBI7co245lHBABWikk8VfejQSlCtDBXn644ZMtAdoxKNfR2WTFVEwJ
        iyd1Fzx0yujuiXDROLhISLQDRjVVAvawrAtLZWYK31bY7KlezPlQnl/D9Asxe85l
        8jO5+0LdJ6VyOs/Hd4w52alDW/MFySDZSfQHMTIc30hLBJ8OnCEIvluVQQ2UQvoW
        +no177N9L2Y+M9TcTA62ZyMXShHQGeh20rb4kK8f+iFX8NxtdHVSkxMEFSfDDyQ=
        </ca>

        disable-occ
      '';
      autoStart = false;
      updateResolvConf = true;
     # };
    };
  };

  virtualisation.docker.enable = true;
  users.users.spiros.extraGroups = [ "docker" ];

  # Activation script to generate the self-signed SSL certificate and key
  system.activationScripts.postgresSSL = ''
    SSL_DIR="/var/lib/postgresql/ssl"

    # Ensure the SSL directory exists with correct permissions
    if [ ! -d "$SSL_DIR" ]; then
      mkdir -p "$SSL_DIR"
      chown postgres:postgres "$SSL_DIR"
      chmod 700 "$SSL_DIR"
    fi

    # Generate the SSL certificate and key if they don't already exist
    if [ ! -f "$SSL_DIR/server.key" ]; then
      ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -nodes -text \
        -out "$SSL_DIR/server.crt" \
        -keyout "$SSL_DIR/server.key" \
        -subj "/CN=localhost"

      chown postgres:postgres "$SSL_DIR/server.key" "$SSL_DIR/server.crt"
      chmod 600 "$SSL_DIR/server.key"
      chmod 644 "$SSL_DIR/server.crt"
    fi
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
