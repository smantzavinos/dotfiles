
{ config, lib, pkgs, ... }:

{
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # services.plex = {
  #   enable = true;
  #   openFirewall = true;
  # };

  # hdhomerun ports
  # networking.firewall.allowedTCPPorts = [ 65001 ];
  # networking.firewall.allowedUDPPorts = [ 1900 5353 65001 ];
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


  # networking = {
  #   interfaces = {
  #     lo = {
  #       useMulticast = true;
  #     };
  #   };
  #   # igmp = {
  #   #   enable = true;
  #   # };
  # };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true;
      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
  };
}
