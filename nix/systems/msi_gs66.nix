# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

let
  # Plex TCP ports. 32400 for accees from web clients
  plexTCPPorts = [ 32400 443 ];
  # Combine all TCP ports into one list
  allowedTCPPorts = plexTCPPorts;

  # Plex UDP ports
  plexUDPPorts = [ 32410 32412 32413 32414 32469 ];
  # SSDP port for UPnP/DLNA device discovery
  ssdpPorts = [ 1900 ];
  # mDNS port for local network service discovery
  mdnsPorts = [ 5353 ];
  # HDHomeRun discovery port
  hdhomerunPorts = [ 65001 ];
  # Additional HDHomeRun ports observed in logs
  additionalUDPPorts = [ 35407 ];
  # Combine all UDP ports into one list
  allowedUDPPorts = plexUDPPorts ++ ssdpPorts ++ mdnsPorts ++ hdhomerunPorts ++ additionalUDPPorts;
in {

  # LUKS configuration for encrypted devices
  boot.initrd.luks.devices = {
    raid1_drive1 = {
      device = "/dev/disk/by-uuid/190975db-2523-41e1-a3dd-99259db3fa06";
      preLVM = true;
    };
    raid1_drive2 = {
      device = "/dev/disk/by-uuid/1d74f573-6e2b-4ecf-9a0c-0fe6e84a4af8";
      preLVM = true;
    };
  };

  # Mount the decrypted Btrfs RAID 1
  fileSystems."/mnt/raid1" = {
    device = "UUID=e8b3cd29-8d42-4a11-aeeb-7a359a54b4ed";
    fsType = "btrfs";
    options = [ "compress=zstd" "degraded" "nofail" ];
    mountPoint = "/mnt/raid1";
  };


  # Kernel params to allow degraded RAID
  boot.kernelParams = [ "btrfs-degraded" "rootdelay=10" ];



  # Nextcloud
  # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  sops.secrets = {
    nextcloudAdminPass = {
      sopsFile = ../secrets/nextcloud-admin-pass.txt;
      format = "binary";
      owner = "nextcloud";
      group = "nextcloud";
    };

    nextcloudDBPass = {
      sopsFile = ../secrets/nextcloud-db-pass.txt;
      format = "binary";
      owner = "nextcloud";
      group = "nextcloud";
    };

    minioCredentials = {
      sopsFile = ../secrets/minio-credentials.txt;
      format = "binary";
      owner = "nextcloud";
      group = "nextcloud";
    };
  };

  # environment.etc."nextcloud-admin-pass".text = "PWD";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = "localhost";
    config.adminpassFile = config.sops.secrets.nextcloudAdminPass.path;


    # Let NixOS install and configure the database automatically.
    database.createLocally = true;

    # Let NixOS install and configure Redis caching automatically.
    configureRedis = true;

    autoUpdateApps.enable = true;
    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      inherit calendar contacts mail notes tasks forms integration_openai music onlyoffice;
    };

    # config.objectstore.s3 = {
    #   enable = true;
    #   bucket = "nextcloud";
    #   autocreate = true;
    #   key = accessKey;
    #   secretFile = "${pkgs.writeText "secret" "test12345"}";
    #   hostname = "localhost";
    #   useSsl = false;
    #   port = 9000;
    #   usePathStyle = true;
    #   region = "us-east-1";
    # };

    # dataDir = /mnt/raid1/nextcloud/data;
    # extraConfig = ''
    #   'datadirectory' => '/mnt/raid1/nextcloud/data',
    # '';

    config = {
      # only specify dbtype if using postgresql db
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      # default directory for postgresql, ensures automatic setup of db
      dbhost = "/run/postgresql";
      adminuser = "admin";
      # specified using agenix, provide path to file as alternative
      # adminpassFile = config.age.secrets.nextcloudPass.path;
      # error thrown unless specified
      # defaultPhoneRegion = "AU";
    };

    # specify only if you want redis caching
    # extraOptions = {
    #   redis = {
    #     host = "127.0.0.1";
    #     port = 31638;
    #     dbindex = 0;
    #     timeout = 1.5;
    #   };
    # };

    settings = {
      datadirectory = "/mnt/raid1/nextcloud/data";  # Set the custom data directory
      # Add other Nextcloud settings here
    };
  };

  # Add nextcloud to users group so it has access to raid drive
  # TODO: UNCOMMENT THIS <<<<<<<<<<<<<<<<<<<-----------------------------------------
  # users.users.nextcloud = {
  #   isSystemUser = true;
  #   extraGroups = [ "users" ];  # Add postgres to the users group
  # };
  # TODO: UNCOMMENT THIS <<<<<<<<<<<<<<<<<<<-----------------------------------------



  # config from:
  # https://mich-murphy.com/configure-nextcloud-nixos/
  ####################
  services = {
    postgresql = {
      # package defined in system_shared.nix
      ensureDatabases = [ "nextcloud" ];
      ensureUsers = [{
        name = "nextcloud";
        ensureDBOwnership = true;
      }];
    };

    # optional backup for postgresql db
    # postgresqlBackup = {
    #   enable = true;
    #   location = "/data/backup/nextclouddb";
    #   databases = [ "nextcloud" ];
    #   # time to start backup in systemd.time format
    #   startAt = "*-*-* 23:15:00";
    # };
  };

  # Add postgres to users group so it has access to raid drive
  # users.users.postgres = {
  #   isSystemUser = true;
  #   extraGroups = [ "users" ];  # Add postgres to the users group
  # };


  systemd = {
    services."apply-postgres-permissions" = {
      description = "Apply custom PostgreSQL permissions";
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      serviceConfig = {
        User = "postgres";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.postgresql_16}/bin/psql -U postgres -d nextcloud -c \"GRANT ALL PRIVILEGES ON DATABASE nextcloud TO nextcloud;\"'";
      };
      wantedBy = [ "multi-user.target" ];
    };

    # Extend the nextcloud-setup service to require and run after permissions are applied
    services."nextcloud-setup" = {
      requires = [ "postgresql.service" "apply-postgres-permissions.service" ];  # Add the new dependency
      after = [ "postgresql.service" "apply-postgres-permissions.service" ];     # Ensure it runs after the permission service
    };
  };

  ####################


  # config from:
  # https://www.addictivetips.com/ubuntu-linux-tips/how-to-set-up-nextcloud-on-nixos/
  ####################
  # Environment setup for Nextcloud admin and database passwords
  # environment.etc."nextcloud-admin-pass".text = "SECURE_PASSWORD_HERE";
  # environment.etc."nextcloud-db-pass".text = "SECURE_PASSWORD_HERE";

  # PostgreSQL service configuration
  # services.postgresql = {
  #   enable = true;
  #   package = pkgs.postgresql_14;  # Adjust the PostgreSQL version as needed
  #   initialScript = pkgs.writeText "nextcloud-db-init.sql" ''
  #     CREATE ROLE nextcloud WITH LOGIN PASSWORD 'SECURE_PASSWORD_HERE';
  #     CREATE DATABASE nextcloud WITH OWNER nextcloud;
  #   '';
  # };

  # # PHP-FPM service configuration for Nextcloud
  # services.phpfpm.pools.nextcloud = {
  #   user = "nextcloud";
  #   group = "nextcloud";
  #   phpOptions = ''
  #     upload_max_filesize = 1G
  #     post_max_size = 1G
  #     memory_limit = 512M
  #     max_execution_time = 300
  #     date.timezone = "America/Detroit"
  #   '';
  # };
  ####################


  # services.minio = {
  #   enable = true;
  #   listenAddress = "127.0.0.1:9000";
  #   consoleAddress = "127.0.0.1:9001";
  #   rootCredentialsFile = config.sops.secrets.minioCredentials.path;
  #   dataDir = ["/mnt/raid1/nextcloud/minio/data"];
  #   configDir = "/mnt/raid1/nextcloud/minio/config";
  #   # user = "spiros";
  #   # group = "spiros";
  # };

  # __________________________________________________


  services.plex = {
    enable = true;
    openFirewall = true;
    user = "spiros";
    dataDir = "/mnt/raid1/PlexMediaServer";
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = allowedTCPPorts;
    allowedUDPPorts = allowedUDPPorts;

    # Firewall pre-commands to allow incoming UDP traffic from local network to ephemeral ports
    extraCommands = ''
      # Allow incoming UDP traffic from local network (192.168.1.0/24) to ephemeral ports (32768-60999)
      iptables -A INPUT -i enp61s0 -s 192.168.1.0/24 -p udp --dport 32768:60999 -j ACCEPT
      iptables -A INPUT -i wlo1 -s 192.168.1.0/24 -p udp --dport 32768:60999 -j ACCEPT
      # Allow established and related connections (important for UDP as it's stateless)
      iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      # Allow traffic on the loopback interface
      iptables -A INPUT -i lo -j ACCEPT
    '';

    # helpful for debugging firewall rules
    # logRefusedPackets = true;
  };



  # Original /etc/nixos/configuration.nix below here
  #####################################################################

  # imports =
  #   [ # Include the results of the hardware scan.
  #      ./hardware-configuration.nix
  #   ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-0dd0154d-6aea-42f9-a913-7d1ae299cad3".device = "/dev/disk/by-uuid/0dd0154d-6aea-42f9-a913-7d1ae299cad3";
  boot.initrd.luks.devices."luks-0dd0154d-6aea-42f9-a913-7d1ae299cad3".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.spiros = {
    isNormalUser = true;
    description = "Spiros Mantzavinos";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    git
    btrfs-progs
    minio-client
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?


  # Original /etc/nixos/hardware-configuration.nix below here
  #####################################################################

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "uas" ];
  boot.initrd.kernelModules = [ ];
  # Add IGC network driver configuration
  boot.extraModprobeConfig = ''
    options igc InterruptThrottleRate=3000,3000,3000,3000 
    options igc max_speed=2500
  '';

  # Ensure the IGC module is loaded
  boot.kernelModules = [ "kvm-intel" "igc" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/7a31c797-5dc4-4e78-9c58-7d1a27223354";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-b348dff0-ff7e-4541-8937-dc2ebdf72e9a".device = "/dev/disk/by-uuid/b348dff0-ff7e-4541-8937-dc2ebdf72e9a";

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/E277-A985";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/43516172-9cff-4af9-9bea-a852f5b633d8"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp61s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
