
{ pkgs, inputs, flags, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver =  {
    xkb.options = "ctrl:nocaps";
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  # secrets management
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/spiros/.config/sops/age/keys.txt";

  # networking.firewall.enable = false;

  # hdhomerun ports
  # networking.firewall.allowedTCPPorts = [ 65001 ];
  # networking.firewall.allowedUDPPorts = [ 65001 ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;
  users.users.spiros.extraGroups = [ "docker" ];

  # programs.steam = {
  #   enable = flags.enableSteam; # NOTE: Accessing flags on Lenovo X1 Extreme was failing here.
                                  #       Seems to be working fine on other systems.
  #   remotePlay.openFirewall = true;
  #   dedicatedServer.openFirewall = true;
  # };
}
