
{ pkgs, flags, ... }:

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
  ];

  networking.firewall.enable = false;

  # hdhomerun ports
  networking.firewall.allowedTCPPorts = [ 65001 ];
  networking.firewall.allowedUDPPorts = [ 65001 ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;
  users.users.spiros.extraGroups = [ "docker" ];

  programs.steam = {
    enable = flags.enableSteam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
