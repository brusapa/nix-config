{ config, ... }:
{
  services.qbittorrent = {
    enable = true;
    user = "transmission";
    group = "media";
    webuiPort = 18080;
    torrentingPort = 56259;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        General.StatusbarExternalIPDisplayed = true;
        WebUI = {
          Username = "bruno";
          Password_PBKDF2 = "@ByteArray(2hlmZ664T9hJbvtGLe3RzQ==:IOthdgiGI0GAzTgH8tTidtSwwSwF+mHha0GNxDw5tPfgnzUOcDHX8v4u7XpFpmN8I68e43SkPL6/J9/a7FuwZA==)";
          CSRFProtection = false;
          ClickjackingProtection = false;
          HostHeaderValidation = false;
          SecureCookie = false;
        };
      };
      Core.AutoDeleteAddedTorrentFile = "IfAdded";
      BitTorrent.Session = {
        Preallocation = true;
        DefaultSavePath = "/zstorage/media/torrents";
        TempPath = "/mnt/internalBackup/downloads/torrent";
        TempPathEnabled = true;
        DisableAutoTMMByDefault = false;
        DisableAutoTMMTriggers = {
          CategorySavePathChanged = false;
          DefaultSavePathChanged = false;
        };
      };
      Network.PortForwardingEnabled = false;
    };
  };

  # Serve it through VPN
  vpnNamespaces.wg = {
    portMappings = [{
      from = config.services.qbittorrent.webuiPort;
      to = config.services.qbittorrent.webuiPort;
    }];
  };
  systemd.services.qbittorrent.vpnconfinement = {
    enable = true;
    vpnnamespace = "wg";
  };

  networking.firewall.allowedTCPPorts = [ config.services.qbittorrent.torrentingPort ];

  services.caddy.virtualHosts."qbittorrent.brusapa.com".extraConfig = ''
    reverse_proxy http://192.168.15.1:${toString config.services.qbittorrent.webuiPort}
  '';
}