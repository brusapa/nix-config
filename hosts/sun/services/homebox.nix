{ config, ... }:
{
  services.homebox = {
    enable = true;
    settings = {
      HBOX_WEB_PORT = "7745";
      HBOX_DATABASE_DRIVER = "sqlite3";
      HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
      HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
      HBOX_MODE = "production";
      HBOX_MAILER_HOST = "localhost";
      HBOX_MAILER_PORT = "25";
      HBOX_MAILER_FROM = "cosas@brusapa.com";
    };
  };
  services.caddy.virtualHosts."cosas.brusapa.com".extraConfig = ''
    reverse_proxy http://127.0.0.1:${toString config.services.homebox.settings.HBOX_WEB_PORT}
  '';
}
