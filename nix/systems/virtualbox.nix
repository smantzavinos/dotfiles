{ config, pkgs, lib, ... }:

{
  # See this PR for when the virtualbox-demo.nix file was removed:
  # https://github.com/NixOS/nixpkgs/pull/354282/files
  # ##################################################

  imports = [];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget vim git nodejs_22
  ];

  # virtualbox guest additions
  virtualisation.virtualbox.guest.enable = true;

  # Enable the X11 server
  services.xserver.enable = true;

  # Choose a display manager (e.g., SDDM for Plasma)
  services.xserver.displayManager.sddm.enable = true;

  # Enable a desktop environment (e.g., Plasma 5)
  services.xserver.desktopManager.plasma5.enable = true;

  # Ensure the user 'spiros' is set up correctly
  users.users.spiros = {
    isNormalUser = true;
    home = "/home/spiros";
    description = "Spiros";
    extraGroups = [ "wheel" "networkmanager" "vboxsf" ];
  };

  users.users.demo = {
    isNormalUser = true;
    description = "Demo user account";

    # vboxsf to allow mounting of shared folders.
    extraGroups = [ "wheel" "vboxsf" ];
    password = "demo";
    uid = 1000;
  };

  # Enable auto-login for convenience (optional)
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "spiros";

  # Bootloader configuration
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
    fsIdentifier = "provided";
  };

  # File systems configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Video drivers for virtual environments
  services.xserver.videoDrivers = [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];

  # Disable power management in a VM
  powerManagement.enable = false;

  # Set the system state version to match your NixOS version
  system.stateVersion = "25.05";

}
