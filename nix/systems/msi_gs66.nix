# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, modulesPath, ... }:

{

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





  services.plex = {
    enable = true;
    openFirewall = true;
    user = "spiros";
    # TODO: Drive should be mapped by uuid
    dataDir = "/run/media/spiros/TOURO/PlexMediaServer";
  };

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 32400 ];
  #   allowedUDPPorts = [ 1900 5353 65001 ];

  #   # Allow all traffic on the local network
  #   extraCommands = ''
  #     iptables -A INPUT -i eth0 -s 192.168.0.0/24 -j ACCEPT
  #   '';
  # };

  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 32400 443 ];  # Include 443 for HTTPS/TLS connections
    allowedUDPPorts = [ 1900 5353 32410 32412 32413 32414 32469 65001 ];  # Plex discovery ports and SSDP

    # Allow all traffic on the local network
    extraCommands = ''
      iptables -A INPUT -i eth0 -s 192.168.0.0/24 -j ACCEPT
      iptables -A INPUT -i lo -j ACCEPT
      ip6tables -A INPUT -i eth0 -s fd29:1cdd:dd43::/64 -j ACCEPT
      ip6tables -A INPUT -i lo -j ACCEPT
    '';
  };


  # Enable Avahi for mDNS
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  # hdhomerun ports
  # networking = {
  #   firewall = {
  #     enable = false;
  #     allowedTCPPorts = [ 65001 ];
  #     allowedUDPPorts = [ 1900 5353 65001 ];

  #     # Allowing multicast DNS and UPnP traffic
  #     # extraCommands = ''
  #     #   iptables -A INPUT -p udp -m udp --dport 1900 -j ACCEPT
  #     #   iptables -A INPUT -p udp -m udp --dport 5353 -j ACCEPT
  #     #   iptables -A INPUT -m pkttype --pkt-type multicast -j ACCEPT
  #     # '';

  #     extraCommands = ''
  #       # Allow multicast traffic
  #       iptables -A INPUT -p igmp -j ACCEPT
  #       iptables -A INPUT -d 239.0.0.0/8 -j ACCEPT
  #       iptables -A INPUT -p udp --dport 1900 -j ACCEPT

  #       # Allow Plex to communicate with HDHomeRun
  #       iptables -A INPUT -p udp --dport 32400 -j ACCEPT
  #       iptables -A INPUT -p udp --dport 32410 -j ACCEPT
  #       iptables -A INPUT -p udp --dport 32412 -j ACCEPT
  #       iptables -A INPUT -p udp --dport 32413 -j ACCEPT
  #       iptables -A INPUT -p udp --dport 32414 -j ACCEPT
  #     '';
  #   };
  # };

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
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
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
  system.stateVersion = "22.11"; # Did you read the comment?


  # Original /etc/nixos/hardware-configuration.nix below here
  #####################################################################

  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "uas" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
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
