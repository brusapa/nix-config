{ self, lib, ... }:
{
  flake.modules.nixos.sun = {
    networking = {
      useDHCP = true;
      useNetworkd = true;
      hostName = "sun";
      domain = "brusapa.com";
      hostId = "696795a0";
    };
    systemd.network.wait-online.enable = true;

    systemd.network.links = {
      "10-lan1s1g" = {
        matchConfig.MACAddress = "9c:6b:00:45:80:66";
        linkConfig.Name = "lan1s1g";
      };
      "10-lan2s1g" = {
        matchConfig.MACAddress = "9c:6b:00:45:80:67";
        linkConfig.Name = "lan2s1g";
      };
      "10-lan3s10g" = {
        matchConfig.MACAddress = "9c:6b:00:45:80:68";
        linkConfig.Name = "lan3s10g";
      };
      "10-lan4s10g" = {
        matchConfig.MACAddress = "9c:6b:00:45:80:69";
        linkConfig.Name = "lan4s10g";
      };
    };
  };
}