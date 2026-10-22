{
  den.aspects.samba-client.nixos =
    { pkgs, ... }:
    {

      environment.systemPackages = with pkgs; [
        cifs-utils # For mount.cifs, required unless domain name resolution is not needed.
      ];

      # Allow samba replies through the firewall
      networking.firewall.extraInputRules = ''
        ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } udp sport 137 accept
      '';
    };
}
