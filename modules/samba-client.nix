{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    cifs-utils # For mount.cifs, required unless domain name resolution is not needed.
  ];

  # Allow samba through the firewall
  networking.firewall.extraCommands = ''iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns'';

}