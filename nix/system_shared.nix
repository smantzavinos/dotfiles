
{ pkgs, ... }:

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;
  users.users.spiros.extraGroups = [ "docker" ];

  programs.steam = {
    enable = false;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    # enable = false;
    # remotePlay.openFirewall = flags.enableSteam;
    # dedicatedServer.openFirewall = flags.enableSteam;
  };
}
